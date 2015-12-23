 #!/bin/bash

#### CODE : un # est un commentaire normal
####        deux # est une note



# DEBUT INTRO

clear


# Si il ny pas dargument, on fait un ls des .cpp du répertoir

if [ $# -eq 0 ]
then
   ls -l | tail -n +2 | egrep \(*.cpp$\|*.cc$\) | cut -d' ' -f 13 
else 
   echo "il y a des arguments"
fi

## $# est le nombre de paramètres passés au script

#     Si il y a des .cpp
#         on demande à lutilisateur decrire le nom du fichier .cpp.
#     Sinon (sil ny a pas de .cpp après ce ls, on utilise le TEMPLATE)
 
# Sinon sil y a un argument
#     on regarde si l'argument fini par .cpp.

# Sinon (dans ce cas là il y a plus d'un argument)
#    il y a erreur car il y a plusieurs fichiers sélectionnés !


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
