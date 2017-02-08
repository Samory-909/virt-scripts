#!/bin/bash

user=$1
guest=$2
guest2=$3
virsh_path=/usr/bin/virsh


ssh1="/usr/bin/ssh root@${guest}"
virsh1="$virsh_path start $guest"
virsh2="$virsh_path destroy $guest"
virsh3="$virsh_path console $guest"
virsh4="$virsh_path start $guest2"
virsh5="$virsh_path destroy $guest2"
virsh6="$virsh_path console $guest2"
echo "%${user} ALL=/bin/usr/sudo, $ssh1, $virsh1, $virsh2, $virsh3, $virsh4, $virsh5, $virsh6"
