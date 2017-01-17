#!/bin/bash

vmname=$(whiptail --title "Virt-Scripts Nom de la VM" --inputbox "Quel est le nom de la VM ?" 10 60 vm1  3>&1 1>&2 2>&3)
distro=$(whiptail --title "Menu Box" --radiolist "Choisissez votre distriubtion linux" 10 60 3 \
"ubuntu" "Ubuntu 16.04 LTS" ON \
"debian" "Debian 8 (Jessie)" OFF \
"centos" "Centos 7" OFF  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
./auto-install.sh $distro $vmname
else
    echo "vous avez annulé"
fi

