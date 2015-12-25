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

# Fonction features

voir()
{
    echo
}

editer()
{
    nano -Kim $fictoedit.cpp
}

generer()
{
    g++ -c $fictoedit.cpp -o $fictoedit.o -Wall -Wextra -O3 -s 2> $fictoedit.stderr ## Compilation
  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        sleep 0.02
    done
   } | whiptail --gauge "Veuillez patienter, je m'occupe de la compilation" 0 0 0
    if [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ]
    then
        msgbox "Informations" "Compilation terminée avec succès"
    else
        if (whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "La compilation ne s'est pas bien effectuée" 0 0)
        then
            msgbox "Sortie d'erreur" "$(cat $fictoedit.stderr)"
        fi
    fi

    msgbox "Informations" "Procédons à l'édition des liens"

    g++ -o $fictoedit.exe $fictoedit.o 2> $fictoedit.stderr ## Edition de liens
  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        echo 0.02
    done
   } | whiptail --gauge "Veuillez patienter, je génère l'exécutable" 0 0 0
    if [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ]
    then
        msgbox "Informations" "Génération terminée avec succès"
    else
        if (whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "Il a eu des problèmes à l'édition de liens" 0 0)
        then
            msgbox "Sortie d'erreur" "$(cat $fictoedit.stderr)"
        fi
    fi

    rm -f $fictoedit.stderr
}

lancer()
{
    if test -f $fictoedit.exe
    then
        chmod 111 $fictoedit.exe
        $fictoedit.exe 2> $fictoedit.stderr

        echo
        if [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ]
        then
            echo "Le programme s'est bien exécuté"
        else
            cat $fictoedit.stderr
        fi

        echo "Saisir \"ok\" pour continuer"
        ok="true"
        while [ $ok != "ok" ]
        do
            read ok
        done

        clear
        rm -f $fictoedit.stderr
    else
        msgbox "Attention !" "Il n'existe pas encore d'executable."
    fi
}

debugguer()
{
    msgbox "" "pas dispo"
}

imprimer()
{
    msgbox "" "pas dispo"
}

shell()
{
    chmod 700 shell.sh
    shell.sh $fictoedit
}

quitter()
{
  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        sleep 0.01
    done
   } | whiptail --gauge "Veuillez patienter, le client va fermer" 0 0 0
}

# FIN FONCTIONS

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
        echo -e "- \033[31mV\033[0moir" # m
        echo -e "- Edit\033[31me\033[0mr" # e
        echo -e "- Géné\033[31mr\033[0m" # r
        echo -e "- Lan\033[31mc\033[0mer" # c
        echo -e "- Débug\033[31mg\033[0mer" # g
        echo -e "- Im\033[31mp\033[0mrimer" # p
        echo -e "- Inter\033[31mf\033[0mace graphique" # f
        echo -e "- \033[31mQ\033[0muitter" # q
        echo

        read reponse # On demande une réponse à l'utilisateur tant que sa réponse est incorrecte
        if [ $reponse = "exit" ]
        then
            clear
            whiptail --title "Rebonjour" --msgbox "Ravi de vous revoir !" 0 0
            exit 1
        fi

        case $reponse in
        $(echo $reponse | egrep ("m"|"M"))
            echo "m"
            ;;
        [eE]*)
            echo "e"
            ;;
        [rR]*)
            echo "r"
            ;;
        [cC]*)
            echo "c"
            ;;
        [gG]*)
            echo "g"
            ;;
        [pP]*)
            echo "p"
            ;;
        [fF]*)
            echo "f"
            ;;
        [qQ]*)
            echo "q"
            ;;
        *)
            echo AHHH
            exit 1
            ;;
        esac


   done


# FIN MENU

