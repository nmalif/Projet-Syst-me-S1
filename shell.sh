 #!/bin/bash

#### version shell

maketemplate()
{
    touch template.cpp
    echo "#include <iostream>" > template.cpp
    echo "#include <cstdlib>" >> template.cpp
    echo >> template.cpp
    echo "using namespace std;" >> template.cpp
    echo >> template.cpp
    echo "int main(int argc, char *argv[])" >> template.cpp
    echo "{" >> template.cpp
    echo "    cout << \"Hello World !\" << endl;" >> template.cpp
    echo "    return EXIT_SUCCESS;" >> template.cpp
    echo "}" >> template.cpp
}

# Fonction FEATURES

voir()
{
   if [ $(wc -c $fictoedit.$extension | cut -d' ' -f 1) = 0 ]
   then
       msgbox "Le fichier est vide" ""
   else
       if (whiptail --title "Voici le contenu du fichier $fictoedit" --yes-button "Colorier" --no-button "Ok" --defaultno --yesno "$(cat $fictoedit\.$extension)" 0 0)
       then
           nano -v $fictoedit.$extension
       fi
   fi
}

editer()
{
    nano -Kim $fictoedit.$extension
}

generer()
{
    if (whiptail --title "Mode de la compilation" --yes-button "Debug" --no-button "Release" --yesno "Debug : permet un débuggage plus facile (conseillé)\nRelease : réduit grandement le poids de l'éxécutable" 0 0)
    then
    	repertoire="debug_$fictoedit"
	if ! test -r $repertoire/
        then
             mkdir $repertoire
        fi
        g++ -g -c $fictoedit.$extension -o $fictoedit.o -Wall -Wextra -pedantic -Wfloat-equal -Wconversion -Wshadow -Weffc++ -Wdouble-promotion -Winit-self -Wswitch-default -Wlogical-op -Wundef -Wswitch-enum 2> $repertoire/$fictoedit.stderr ## Compilation Debug
    else
    	repertoire="release_$fictoedit"
	if ! test -r $repertoire/
        then
            mkdir $repertoire
	fi
	g++ -c $fictoedit.$extension -o $fictoedit.o -O3 -s 2> $repertoire/$fictoedit.stderr ## Compilation Release
    fi

    mv $fictoedit.o $repertoire/$fictoedit.o

  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        sleep 0.02
    done
   } | whiptail --gauge "Veuillez patienter, je m'occupe de la compilation" 0 0 0

    if [ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ]
    then
        msgbox "Informations" "Compilation terminée avec succès"
    else
        if (whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "La compilation ne s'est pas effectuée parfaitement" 0 0)
        then
            msgbox "Sortie d'erreur" "$(cat $repertoire/$fictoedit.stderr)"
        fi
    fi

    if test -f $repertoire/$fictoedit.o
    then
        msgbox "Informations" "Procédons à l'édition des liens"
    fi

    g++ -o $repertoire/$fictoedit.exe $repertoire/$fictoedit.o 2> $repertoire/$fictoedit.stderr ## Edition de liens
  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        echo 0.02
    done
   } | whiptail --gauge "Veuillez patienter, je génère l'exécutable" 0 0 0
    if [ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ]
    then
        msgbox "Informations" "Génération terminée."
    else
        if (whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "Il a eu des problèmes à l'édition de liens" 0 0)
        then
            msgbox "Sortie d'erreur" "$(cat $repertoire/$fictoedit.stderr)"
        fi
    fi
}

lancer()
{
    local exec="false"
    local prog="true"

    if test -f release_$fictoedit/$fictoedit.exe
    then
        exec="true"
	cd release_$fictoedit/
    elif test -f debug_$fictoedit/$fictoedit.exe
    then
        exec="true"
        cd debug_$fictoedit/
    else
        msgbox "Attention !" "Il n'existe pas encore d'executable."
    fi

    if $exec
    then
        chmod 111 $fictoedit.exe
        $fictoedit.exe 2> $fictoeditt.stderr
        echo
        if [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ]
        then
            echo "Le programme s'est bien exécuté"
        else
            cat $fictoedit.stderr
        fi

        echo "Appuyez sur \"Entrée\" pour continuer"
        while [ $prog != "" ]
        do
            read prog
        done

        clear
        rm -f $fictoedit.stderr

        cd ..
    fi
}

debugguer()
{
    if test -f debug_$fictoedit/$fictoedit.exe
    then
        msgbox "Informations" "Saisir \"quit\" pour revenir."
        gdb debug_$fictoedit/$fictoedit.exe
    else
        msgbox "Attention !" "Il n'y a rien à débugguer ici, peut-être devriez-vous générer un éxécutatable en mode \"Debug\" ?"
    fi
}

imprimer()
{
    msgbox "" "pas dispo"
}

shell()
{
    msgbox "Informations" "Vous allez passer en mode en mode Shell, pour revenir en mode affichage graphique, il faudra saisir \"exit\""
    chmod 700 shell.sh
    shell.sh $fictoedit
}

quitter()
{
   msgbox "GNU GPL V3.0 License" "A très bientôt ! ^^"
}
## FIN FONCTIONS

# DEBUT INTRO

clear

fictoedit=""
continuer=true # un simple booléen
reponse=""


ls -l | egrep \(*.cpp$\|*.cc$\) | grep -o "[^ ]*$" | cut -d'.' -f 1 > temp
if [ $# -eq 0 ] # Si il ny pas dargument
then # alors on met le nom de tous les fichiers .cc et .cpp dans un fichier temp
   if [ $(wc -l temp | cut -d' ' -f 1) -eq 0 ] # sil ny a pas de .cpp ou .cc dans le repertoire alors on utilise le TEMPLATE
   then
      echo "Il n'y a pas de .cpp..."
      echo "... un template a été automatiquement crée !"
      maketemplate
      while $continuer
          do
              echo -n "Donnez lui un nom : "
              read fictoedit
              if [ $fictoedit = "exit" ]
              then
                  exit 1
              fi
              echo "Êtes-vous sûr ?"
              read reponse
              if [ $reponse = "exit" ]
              then
                  exit 1
              fi
              if [ $reponse = 'oui' ] || [ $reponse = 'Oui' ]
              then
                  continuer=false
              fi
          done
      continuer=true
      mv template.cpp $fictoedit.cpp
   else # sinon on les montre
      while $continuer
          do
              echo "Voici les fichiers sources c++ du répertoire :"
              echo " "
              cat temp
              echo " "
              echo -n "Ecrire le nom du fichier source c++ à manipuler : "
              # puis on demande a l'utilisateur decrire le nom du fichier quil veut manipuler
              read fictoedit
              if [ $fictoedit = "exit" ]
              then
              	  exit 1
              fi
              if [ $(grep -cx $fictoedit temp) != 0 ] # Cela veut dire que l'utilisateur a écrit un nom qui existait
              then
                  echo
                  echo -e "Vous avez choisi\033[31m" $fictoedit "\033[0mcomme fichier à manipuler"
                  continuer=false
                  echo
              else
                  clear
                  echo "Ce fichier n'existe pas, réessayer s'il vous plait"
                  echo
              fi
          done
       continuer=true
    fi
elif [ $# -eq 1 ] # Sinon sil y a exactement un argument
then
   fictoedit=$(echo $1 | cut -d'.' -f 1)
   echo -ne "Le fichier\033[31m" $fictoedit "\033[0m"
   if  [ $(grep -cx $fictoedit temp) = 1 ] # on regarde si le nom du fichier est présent dans temp, si oui
   then
      echo "est présent"
   else
      echo "n'est pas présent"
      touch $fictoedit.cpp
      echo "Il a donc été crée !"
   fi
else # Sinon (dans ce cas là il y a plus d'un argument) il y a erreur car il y a plusieurs fichiers sélectionnés !
   echo "il y a plus d'un argument, le script s'arrête"
   exit 1
fi

rm -f temp

# FIN INTRO

reponse=""
continuer=true

# DEBUT MENU

    while $continuer
    do
        clear
        echo -e "Vous manipulez le fichier \033[31m$fictoedit\033[0m"
        echo "Que faire avec ?"
        echo -e "Pour choisir, tapez le nom de la fonctionnalité, ou son raccourci écrit en \033[31mrouge\033[0m"
        echo
        echo
        echo -e "- \033[31mV\033[0moir" # v
        echo -e "- Edit\033[31me\033[0mr" # e
        echo -e "- Géné\033[31mr\033[0m" # r
        echo -e "- Lan\033[31mc\033[0mer" # c
        echo -e "- Débug\033[31mg\033[0mer" # g
        echo -e "- Im\033[31mp\033[0mrimer" # p
        echo -e "- \033[31mQ\033[0muitter le script" # q
        echo

        read reponse # On demande une réponse à l'utilisateur tant que sa réponse est incorrecte
        if [ $reponse = "exit" ]
        then
            clear
            whiptail --title "Rebonjour" --msgbox "Ravi de vous revoir !" 0 0
            exit 1
        fi

        case $reponse in
        [vV] | [vV][oO][iI][rR])
            voir
            ;;
        [eE] | [eE][dD][iI][tT][eE][rR])
            editer
            ;;
        [gG] | [gG][eE][nN][eE][rR][eE][rR])
            generer
            ;;
        [cC] | [lL][aA][nN][cC][eE][rR])
            lancer
            ;;
        [gG] | [dD][eE][bB][uU][gG][gG][uU][eE][rR])
            debugguer
            ;;
        [pP] | [iI][mM][pP][rR][iI][mM][eE][rR])
            imprimer
            ;;
        [qQ] | [qQ][uU][iI][tT][tT][eE][rR])
            quitter
            ;;
        *)
            echo AHHH
            exit 1
            ;;
        esac
   done


# FIN MENU

