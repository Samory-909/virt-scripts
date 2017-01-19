#!/bin/bash

os=$1

location=/var/lib/iso
url_ubuntu_iso=http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-8.7.1-amd64-netinst.iso
url_debian_iso=http://cdimage.debian.org/debian-cd/8.6.0/amd64/iso-cd/debian-8.6.0-amd64-netinst.iso
url_centos_iso=http://ftp.belnet.be/ftp.centos.org/7/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso

get_iso () {
mkdir -p $location
cd $location
wget $url
}  

fix_url () {
if [ $os = centos ] ; then
 url=$url_centos_iso
elif [ $os = debian ] ; then
 url=$url_debian_iso
elif [ $os = ubuntu ] ; then
 url=$url_ubuntu_iso
else
 echo "Erreur dans le script : ./get-iso.sh [ centos | debian | ubuntu ]"
 exit
fi
}

fix_url
get_iso
