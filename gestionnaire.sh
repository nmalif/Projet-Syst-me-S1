#!/bin/bash

#### PROJET SYSTEME : DEVELOPPEMENT D'UN IDE POUR C++
#### by Le-Ho et Malifarge

# note : je pense qu'on va utilisé whiptail au lieu de dialog pour une interface graphique
# pour des raisons de portabilité

## FONCTIONS

maketemplate()
{
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

renommerfic()
{
    touch madeon porter # bonjour
    echo $1 > madeon
    echo $2 > porter
    if [ $(cat madeon | cut -d"." -f 1) != $(cat porter | cut -d "." -f 1) ]
    then
        mv "$1" "$2"
    fi
    rm -f madeon porter # aurevoir
}

makefileslist()
{
    ls -l | egrep \(*.cpp$\|*.cc$\) | grep -o "[^ ]*$" | cut -d'.' -f 1 > temp # tous les fichiers sources c++ dans un fichier, ligne par ligne, sans extension
}

# Ce fichier temp est important pour le reste du script


listtomenu() # fabrique une partie du code source de menu.sh, en fait on veut écrire un script en fonction du nombre de fichiers .cpp présents, ainsi que leur nom
{
    if test -f tomenu
    then
        rm -f tomenu
    fi
    local i=0

    while read fichier
    do
       let i++
       echo -n \"$i.\" >> tomenu
       echo -n " " >> tomenu
       printf "%s\n" "\"$fichier\" \\" >> tomenu
    done < temp

    echo "2> fictoedit.dat" >> tomenu
}

makemenuscript() # écriture du script
{
    local nbfic
    let nbfic=$(wc -l temp | cut -d' ' -f 1)

    cat $0 | head -n 1 > menu.sh
    chmod 700 menu.sh
    echo 'whiptail --title "Voici les fichiers sources c++ du répertoire" --nocancel --menu "Chosissez un fichier"' 0 0 $nbfic "\\" >> menu.sh
    cat tomenu >> menu.sh
    echo "sed -i 's/.$//'" \"fictoedit.dat\" >> menu.sh
}

msgbox()
{
    whiptail --title "$1" --msgbox "$2" 0 0
}


inputbox()
{
    input=$(whiptail --title "$1" --inputbox "$2" --nocancel 0 0 "template" \
    3>&1 1>&2 2>&3)
    echo $input > input.dat
}

editionmenu()
{
    whiptail --title "Que faire avec $1 ?" --nocancel --menu "Veuillez choisir un outil :" 0 0 8 \
    "1." "Voir" \
    "2." "Editer" \
    "3." "Générer" \
    "4." "Lancer" \
    "5." "Débugguer" \
    "6." "Imprimer" \
    "7." "Shell" \
    "8." "Quitter" 3>&1 1>&2 2>&3 | cut -d'.' -f 1 > edition.choix
}

# Fonction FEATURES

voir()
{
   if (whiptail --title "Voici le contenu du fichier $fictoedit" --yes-button "Colorier" --no-button "Ok" --defaultno --yesno "$(cat $fictoedit.cpp)" 0 0)
   then
       nano -v $fictoedit.cpp
   fi
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
    msgbox "" "pas dispo"
}

quitter()
{
  { for ((i = 0 ; i <= 100 ; i++))
    do
        echo $i
        sleep 0.01
    done
   } | whiptail --gauge "Veuillez patienter, le client va fermer" 0 0 0
   msgbox "GNU GPL V3.0 License" "A bientôt !" 0 0 0
}
## FIN FONCTIONS



## PROLOGUE
clear
makefileslist
## FIN PROLOGUE

## VARIABLE
fictoedit="" # nom du fichier a manipuler
continuer="true" # booléen-like pour les while
##

## DEBUT INTRO

msgbox "Bienvenue !" "Ceci est un outil d'aide à la programmation en C++, développé par Nathan Malifarge et Viet-Khang Le Ho, pour le projet Système S1."
if [ $# -eq 0 ] # Si il ny pas dargument
then # alors on met le nom de tous les fichiers .cc et .cpp dans un fichier temp
   if [ $(wc -l temp | cut -d' ' -f 1) -eq 0 ] # sil ny a pas de .cpp ou .cc dans le repertoire alors on utilise le TEMPLATE
   then
      msgbox "Informations" "Il n'y a pas de .cpp dans le répertoire courant, un template a été automatiquement crée !"
      maketemplate
      inputbox "Vous pouvez renommer le fichier" "Quel nom voulez-vous lui donner ?"
      renommerfic template.cpp $(cat input.dat).cpp
      fictoedit=$(cat input.dat)
      rm -f input.dat
   else # sinon on les montre
      listtomenu
      makemenuscript
      menu.sh
      fictoedit=$(cat temp | head -n $(cat fictoedit.dat) | tail -n 1) # On prend la n ieme ligne du fichier temp, n étant égal à la sortie d'erreur du script menu.sh (optimisé, sans le .)
      rm -f menu.sh tomenu fictoedit.dat
   fi
elif [ $# -eq 1 ] # Sinon sil y a exactement un argument
then
   echo $1 > arg1
   fictoedit=$(cat arg1 | cut -d'.' -f 1)
   rm -f arg1

   msgbox "Bienvenue !" "Vous avez choisi de manipuler le fichier $fictoedit."
   if  [ $(grep -cx $fictoedit temp) = 1 ] # on regarde si le nom du fichier est présent dans temp, si oui
   then
      msgbox "Informations" "Ce fichier est présent."
   else
      msgbox "Informations" "Ce fichier n'est pas présent, il a donc été crée !"
      maketemplate
      renommerfic template.cpp $fictoedit.cpp
    fi
else # Sinon (dans ce cas là il y a plus d'un argument) il y a erreur car il y a plusieurs fichiers sélectionnés !
   msgbox "ERREUR FATALE" "Il y a plus d'un argument, le script va s'arrêter."
   exit 1
fi

rm -f temp

## FIN INTRO


## DEBUT MENU

while $continuer
do
    editionmenu $fictoedit
    case $(cat edition.choix) in
    1)
        voir
        ;;
    2)
        editer
        ;;
    3)
        generer
        ;;
    4)
        lancer
        ;;
    5)
        debugguer
        ;;
    6)
        imprimer
        ;;
    7)
        shell
        ;;
    8)
        quitter
        continuer="false"
        ;;
    *)
        echo "???? probleme case"
        exit 1
        ;;
    esac
done
rm -f edition.choix

# un truc genre --> voir : 0
#                   éditer : 1
#                   générer : 2
#                   lancer : 3
#                   débugguer :  4 ETC

# On demande une réponse à l'utilisateur tant que sa réponse est incorrecte

## FIN MENU

# DEBUT FEATURES

# voir : less
# éditer : nano  
# générer : séparer compilation avec g++ -o et linkage puis chmod 700 l'exécutable
# lancer : lance l'exécutable
# débugguer : compiler le programme en mode débug 
# imprimer : transformer en pdf puis a2ps ou un print
# shell :
# envoyer par mail 
# quitter : 

# FIN FEATURES

