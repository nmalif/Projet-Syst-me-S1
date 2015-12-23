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
continuer=true

if [ $# -eq 0 ] # Si il ny pas dargument
then # alors on met le nom de tous les fichiers .cc et .cpp dans un fichier temp
   ls -l | egrep \(*.cpp$\|*.cc$\) | cut -d' ' -f 13 | cut -d'.' -f 1 | tail -n +2 > temp
   if [ $(wc -l temp | cut -d' ' -f 1) -eq 0 ] # sil ny a pas de .cpp ou .cc dans le repertoire alors on utilise le TEMPLATE
   then
      echo "Il n'y a pas de .cpp."
      echo "Template automatiquement crée !"
      maketemplate
   else # sinon on les montre
      echo "Voici les fichiers sources c++ du répertoire :"
      echo " "
      cat temp
      echo " "
      echo -n "Ecrire le nom du fichier source c++ à manipuler : "
      # puis on demande a l'utilisateur decrire le nom du fichier quil veut manipuler
      while $continuer
         do
            read fictoedit
            if [ $(grep -cx $fictoedit temp) != 0 ] # Cela veut dire que l'utilisateur a écrit un nom qui existait 
            then 
               continuer=false
            else
               echo "Ce fichier n'existe pas, réessayer s'il vous plait"
            fi 
         done
   fi
   rm -f temp
elif [ $# -eq 1 ] # Sinon sil y a exactement un argument
then # on regarde si l'argument fini par .cpp ou .cc
   if true
   then
      echo "Le test est bon"
   else
      echo "Il n'est pas bon"
   fi
else # Sinon (dans ce cas là il y a plus d'un argument) il y a erreur car il y a plusieurs fichiers sélectionnés !
   echo "il y a plus d'un argument"
fi

## $# est le nombre de paramètres passés au script




# Si c'est le  cas, MENU
# Sinon, dire qu'il y a erreur et redemander un nom correcte de fichier .cpp

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

