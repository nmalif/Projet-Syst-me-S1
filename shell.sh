#!/bin/bash

utilis=$(finger -l | grep Name | cut -d: -f 3 | tail -c +2)
cmd=""
args=""

echo -e "Bienvenue $utilis !\nSaisir \"exit\" ou \"quitter\" pour fermer ce BASH.\n"

while true
do
  echo -n "Commande : "
  read cmd
  args=""
  [ $(echo $cmd | wc -w) != "1" ] && args=$(echo $cmd | cut -d' ' -f2-)
  cmd=$(echo $cmd | cut -d' ' -f 1)
  [ $cmd = exit ] && break
  [ "$(which -a $cmd)" != "" ] && $cmd $args
  [ "$(which -a $cmd)" != "" ] || echo "La commande nexiste pas !"
done
