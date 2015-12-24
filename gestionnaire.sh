 #!/bin/bash

#### PROJET SYSTEME : DEVELOPPEMENT D'UN IDE POUR C++
#### by Le-Ho et Malifarge

# note : je pense qu'on va utilisé whiptail au lieu de dialog pour une interface graphique
# pour des raisons de portabilité

maketemplate()
{
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

listtomenu()
{
    if test tomenu
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
    sed -i '$ s/.$/3>\&2 1>\&2 2>\&3)/' "tomenu"
}

makemenuscript()
{
    local nbfic
    let nbfic=$(wc -l tomenu | cut -d' ' -f 1)

    cat $0 | head -n 1 > menu.sh
    chmod 700 menu.sh
    echo 'fictoedit=$(whiptail --title "Voici les fichiers sources c++ du répertoire" --menu "Chosissez un fichier"' 0 0 $nbfic "\\" >> menu.sh
    cat tomenu >> menu.sh
    echo "if [ \$? = 0 ]" >> menu.sh
    echo "then" >> menu.sh
    echo "    echo \$fictoedit" >> menu.sh
    echo "else" >> menu.sh
    echo "    echo \"Cancel\"" >> menu.sh
    echo "fi" >> menu.sh
}

msgbox()
{
    whiptail --title "$1" --msgbox "$2" 0 0
}

inputbox()
{
    nom=$(whiptail --title "$1" --inputbox "$2" 0 0 template 3>&1 1>&2 2>&3)
    if [ $? = 0 ]
    then
        mv template.cpp $nom.cpp
        echo $nom >> temp
    else
        echo "cancel"
    fi
}


# VARIABLES
fictoedit=""
continuer=true # un simple booléen
reponse=""
var=$(cat tomenu)
# FIN VARIABLES



clear

# DEBUT INTRO

msgbox "Bienvenue !" "Ceci est un outil d'aide à la programmation en C++, développé par Nathan Malifarge et Viet-Khang Le Ho, pour le projet Système S1."

ls -l | egrep \(*.cpp$\|*.cc$\) | grep -o "[^ ]*$" | cut -d'.' -f 1 > temp # tous les fichiers sources c++ dans un fichier, ligne par ligne, sans extension

if [ $# -eq 0 ] # Si il ny pas dargument
then # alors on met le nom de tous les fichiers .cc et .cpp dans un fichier temp
   if [ $(wc -l temp | cut -d' ' -f 1) -eq 0 ] # sil ny a pas de .cpp ou .cc dans le repertoire alors on utilise le TEMPLATE
   then
      msgbox "Il n'y a pas de .cpp dans le répertoire courant" "... un template a été automatiquement crée !"
      maketemplate
      inputbox "Vous pouvez nommer le fichier" "Quel nom voulez-vous lui donner ?"
   else # sinon on les montre
      listtomenu
      makemenuscript
      menu.sh
      rm -f menu.sh tomenu
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
      mv template.cpp $fictoedit.cpp
   fi
   msgbox "Informations" "Vous manipulez le fichier $fictoedit."
else # Sinon (dans ce cas là il y a plus d'un argument) il y a erreur car il y a plusieurs fichiers sélectionnés !
   msgbox "ERREUR FATALE" "Il y a plus d'un argument, le script va s'arrêter."
   exit 1
fi

rm -f temp


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

