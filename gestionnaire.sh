 #!/bin/bash

#### CODE : un # est un commentaire normal
####        deux # est une note

maketemplate()
{  
    touch template.cpp 
    echo "#include <iostream>" > template.cpp
    echo "#include <cstdlib>" >> template.cpp
    echo " " >> template.cpp
    echo "using namespace std;" >> template.cpp
    echo " " >> template.cpp
    echo "int main(int argc, char *argv[])" >> template.cpp
    echo "{" >> template.cpp
    echo "    cout << \"Hello World !\" << endl;" >> template.cpp
    echo "    return EXIT_SUCCESS;" >> template.cpp
    echo "}" >> template.cpp
}


# DEBUT INTRO

clear

fictoedit=""
continuer=true # un simple booléen
reponse=""


ls -l | egrep \(*.cpp$\|*.cc$\) | cut -d' ' -f 13 | cut -d'.' -f 1 | tail -n +2 > temp
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
              echo "Êtes-vous sûr ?"
              read reponse
              if [ $reponse = 'oui' ]
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
              if [ $(grep -cx $fictoedit temp) != 0 ] # Cela veut dire que l'utilisateur a écrit un nom qui existait
              then
                  echo " "
                  echo -e "Vous avez choisi\033[31m" $fictoedit "\033[0mcomme fichier à manipuler"
                  continuer=false
                  echo " "
              else
                  clear
                  echo "Ce fichier n'existe pas, réessayer s'il vous plait"
                  echo " "
              fi
          done
       continuer=true
    fi
elif [ $# -eq 1 ] # Sinon sil y a exactement un argument
then
   fictoedit=$1
   echo -ne "Le fichier\033[31m" $fictoedit "\033[0m"
   if  [ $(grep -cx $1 temp) = 1 ] # on regarde si le nom du fichier est présent dans temp, si oui
   then
      echo "est présent"
   else
      echo "n'est pas présent"
      touch $fictoedit.cpp
      echo "Il a donc été crée !"
   fi
   echo -e "Vous manipulez le fichier \033[31m$fictoedit\033[0m"
else # Sinon (dans ce cas là il y a plus d'un argument) il y a erreur car il y a plusieurs fichiers sélectionnés !
   echo "il y a plus d'un argument, le script s'arrête"
   exit 1
fi

rm -f temp 

## $# est le nombre de paramètres passés au script

# FIN INTRO

# DEBUT MENU

# un truc genre --> voir : 0
#                   éditer : 1
#                   générer : 2
#                   lancer : 3
#                   débugguer :  4 ETC

# On demande une réponse à l'utilisateur tant que sa réponse est incorrecte

# FIN MENU

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

