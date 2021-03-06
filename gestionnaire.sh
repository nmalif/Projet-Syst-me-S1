#!/bin/bash

#### PROJET SYSTEME : DEVELOPPEMENT D'UN IDE POUR C++
#### by Le-Ho et Malifarge

# note : on va utilisé whiptail au lieu de dialog pour une interface graphique pour des raisons de portabilité

## FONCTIONS

aide()
{
  msgbox "Aide" "Usage: gestionnaire.sh [fichier]\n[fichier] est un fichier C++ existant ou pas, donné sans extension.\nC'est un argument facultatif."
  exit 0
}

maketemplate() # Crée un template par défaut
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

makemakefile() # un makefile générique
{
  echo 'CC = g++' > Makefile
  echo 'CFLAGS = -W -Wall -g' >> Makefile
  echo 'LDFLAGS =' >> Makefile
  echo '' >> Makefile
  echo 'SRC = $(wildcard *.cpp)' >> Makefile
  echo 'OBJS = $(SRC:.cpp=.o)' >> Makefile
  echo 'AOUT = prog' >> Makefile
  echo '' >> Makefile
  echo 'all : $(AOUT)' >> Makefile
  echo '' >> Makefile
  echo 'prog : $(OBJS)' >> Makefile
  echo '$(CC) $(LDFLAGS) -o $@ $^' >> Makefile
  echo '%.o : %.cpp' >> Makefile
  echo '$(CC) $(CFLAGS) -o $@ -c $<' >> Makefile
  echo 'clean :' >> Makefile
  echo '@rm *.o' >> Makefile
  echo 'cleaner : clean' >> Makefile
  echo '@rm $(AOUT)' >> Makefile
}

renommerfic()
{
  touch madeon pixel_empire # <<
  echo $1 > madeon
  echo $2 > pixel_empire
  [ $(cat madeon | cut -d"." -f 1) != $(cat pixel_empire | cut -d "." -f 1) ] && mv "$1" "$2"
  rm -f madeon pixel_empire # >>
}

makefileslist()
{
  ls -l | grep -v ^d | egrep \(*.cpp$\|*.cc$\) | grep -o "[^ ]*$" | cut -d'.' -f 1 > temp # tous les fichiers sources c++ dans un fichier, ligne par ligne, sans extension
}

# Ce fichier temp est important pour le reste du script


listtomenu() # fabrique une partie du code source de menu.sh, en fait on veut écrire un script en fonction du nombre de fichiers .cpp présents, ainsi que leur nom
{
  test -f tomenu && rm -f tomenu

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
  input=$(whiptail --title "$1" --inputbox "$2" --nocancel 0 0 "$3" \
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
  "7." "Mail" \
  "8." "Shell" \
  "9." "Supprimer" \
  "10." "Quitter" 3>&1 1>&2 2>&3 | cut -d'.' -f 1 > edition.choix
}

# Fonction FEATURES

voir()
{
  [ $(wc -c $fictoedit.$extension | cut -d' ' -f 1) = 0 ] && msgbox "Le fichier est vide" ""
  [ $(wc -c $fictoedit.$extension | cut -d' ' -f 1) = 0 ] || (whiptail --title "Voici le contenu du fichier $fictoedit" --yes-button "Colorier" --no-button "Ok" --defaultno --yesno "$(cat $fictoedit\.$extension)" 0 0) && nano -v $fictoedit.$extension
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
    ! test -r $repertoire/ && mkdir $repertoire
    g++ -g -c $fictoedit.$extension -o $fictoedit.o -Wall -Wextra -pedantic -Wfloat-equal -Wconversion -Wshadow -Weffc++ -Wdouble-promotion -Winit-self -Wswitch-default -Wlogical-op -Wundef -Wswitch-enum 2> $repertoire/$fictoedit.stderr ## Compilation Debug
  else
    repertoire="release_$fictoedit"
    ! test -r $repertoire/ && mkdir $repertoire
    g++ -c $fictoedit.$extension -o $fictoedit.o -O3 -s 2> $repertoire/$fictoedit.stderr ## Compilation Release
  fi
  mv $fictoedit.o $repertoire/$fictoedit.o

  { for ((i = 0 ; i <= 100 ; i++))
  do
    echo $i
    sleep 0.02
  done
} | whiptail --gauge "Veuillez patienter, je m'occupe de la compilation" 0 0 0

[ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ] && msgbox "Informations" "Compilation terminée avec succès"
[ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ] || ((whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "La compilation ne s'est pas effectuée parfaitement" 0 0) && msgbox "Sortie d'erreur" "$(cat $repertoire/$fictoedit.stderr)")

test -f $repertoire/$fictoedit.o && msgbox "Informations" "Procédons à l'édition des liens"

g++ -o $repertoire/$fictoedit.exe $repertoire/$fictoedit.o 2> $repertoire/$fictoedit.stderr ## Edition de liens

{ for ((i = 0 ; i <= 100 ; i++))
do
  echo $i
  echo 0.02
done
} | whiptail --gauge "Veuillez patienter, je génère l'exécutable" 0 0 0

[ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ] &&  msgbox "Informations" "Génération terminée."
[ $(wc -c $repertoire/$fictoedit.stderr | cut -d' ' -f 1) = 0 ] || ((whiptail --title "Attention !" --yes-button "Voir" --no-button "Ignorer" --defaultno --yesno "Il a eu des problèmes à l'édition de liens" 0 0) && msgbox "Sortie d'erreur" "$(cat $repertoire/$fictoedit.stderr)")
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
    $fictoedit.exe 2> $fictoedit.stderr
    echo
    [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ] && echo "Le programme s'est bien exécuté"
    [ $(wc -c $fictoedit.stderr | cut -d' ' -f 1) = 0 ] || cat $fictoedit.stderr

    echo "Appuyez sur \"Entrée\" pour continuer"
    while [ $prog != "" ]
    do
      read prog
    done

    clear
    cd ..
  fi
}

debugguer()
{
  if test -f debug_$fictoedit/$fictoedit.exe
    then
    msgbox "Informations" "Saisir \"quit\" pour revenir."
    gdb debug_$fictoedit/$fictoedit.exe # Ouvre le client natif de débuggage linux
    clear
  else
    msgbox "Attention !" "Il n'y a rien à débugguer ici, peut-être devriez-vous générer un éxécutatable en mode \"Debug\" ?"
  fi
}

imprimer()
{
  a2ps -q $fictoedit.$extension -o $fictoedit.ps
  ps2pdf $fictoedit.ps $fictoedit.pdf

  if (whiptail --title "Informations" --yes-button "Allons-y" --no-button "Non merci" --yesno "Un fichier pdf a bien été généré, voulez-vous le voir ?" 0 0)
    then
  msgbox "Informations" "Utilisez la souris pour parcourir votre fichier, CTRL+P pour l'imprimer et ALT+F4 pour quitter"
  evince -s $fictoedit.pdf
  clear
  rm -f $fictoedit.ps
  fi
}

mail()
{
  local titre
  local adresse

  msgbox "Informations" "L'envoi concerne le fichier source."
  inputbox "Envoie par mail" "Donner un titre à votre mail" "MonTitre"
  titre=$(cat input.dat)
  rm -f input.dat
  inputbox "Envoie par mail" "Ecrire l'adresse mail" "popculture@exemple.fr"
  adresse=$(cat input.dat)
  rm -f input.dat
  echo | mutt -s $titre -a $1 -- $adresse # Envoi un mail avec le client mutt
  msgbox "Informations" "Le mail a été envoyé, si le destinataire ne reçoit rien, il faut vérifier l'adresse fournie."
}

shell()
{
  msgbox "Informations" "Vous allez passer en mode en mode Shell, pour revenir en mode affichage graphique, il faudra saisir \"exit\""
  gnome-terminal -x "shell.sh" &
  clear
}

supprimer()
{
    if (whiptail --title "Attention !" --yes-button "Oui" --no-button "Non" --yesno "Voulez-vous vraiment supprimer le fichier $fictoedit et tous ses répertoires associés ?" 0 0)
    then
    rm -rf $fictoedit.$extension debug_$fictoedit/ release_$fictoedit/
    msgbox "Informations" "Le fichier a bien été supprimé \n\nA très bientôt !"  
    rm -f editio.choix
    exit 0
    fi
}

quitter()
{
  msgbox "GNU GPL V3.0 License" "A très bientôt !"
}


## FIN FONCTIONS



## PROLOGUE
clear
makefileslist
## FIN PROLOGUE

## VARIABLE
fictoedit="" # nom du fichier a manipuler
extansion="" # cpp ou cc
continuer="true" # booléen-like pour les while
##


## DEBUT

## AIDE
[[ $1 = "--help" || $1 = "-h" || $1 = "--aide" ]] && aide
## FIN AIDE


## DEBUT INTRO

msgbox "Bienvenue !" "Je suis un outil d'aide à la programmation en C++, développé par Viet-Khang Le Ho et Nathan Malifarge dans le cadre du projet Système du S1"
if [ $# -eq 0 ] # Si il ny pas dargument
  then # alors on met le nom de tous les fichiers .cc et .cpp dans un fichier temp
  if [ $(wc -l temp | cut -d' ' -f 1) -eq 0 ] # sil ny a pas de .cpp ou .cc dans le repertoire alors on utilise le TEMPLATE
    then
    msgbox "Informations" "Il n'y a pas de .cpp dans le répertoire courant, un template a été automatiquement crée !"
    maketemplate
    inputbox "Vous pouvez renommer le fichier" "Quel nom voulez-vous lui donner ?" "template"
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

  msgbox "Informations" "Vous avez choisi de manipuler le fichier $fictoedit."
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

test -f $fictoedit.cpp && extension="cpp"
test -f $fictoedit.cc && extension="cc"

## DEBUT MENU
repertoire="."

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
    mail $fictoedit.cpp
    ;;
    8)
    shell
    ;;
    9)
    supprimer
    ;;
    10)
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

