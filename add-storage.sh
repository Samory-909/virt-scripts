#!/bin/bash
#This script attach a disk to a live guest
guest=$1
device=$2
disk=/var/lib/libvirt/images/${1}-${device}.img
size=$3
parameters=$#

check_parameters () {
if [ "$parameters" -ne 3  ] ; then
echo "Description : This script attach a disk to a live guest"
echo "Usage       : $0 <guest name> <block device name> <size in GB>"
echo "Example     : '$0 guest1 vdb 4' add a vdb 4GB disk to guest1"
exit
fi
# check if device exists : virsh domblklist $guest | awk '{ print $1 }' | grep $device
if grep -qvw "$guest" <<< $(virsh list --name)  ; then
echo "Please provide a live guest name : exit"
echo "Guests avaible :"
echo "$(virsh list --name)"
exit
fi
if grep -qw "$device" <<< $(virsh domblklist $guest) ; then
echo "This block device $device is alrady in use"
echo "Block devices in use :"
virsh domblklist $guest
exit
fi
}

add_storage () {
seek=$[${size}*1024]
# Create Spare Disk with dd
dd if=/dev/zero of=$disk  bs=1M seek=$seek count=0
# Or create a qcow2 disk
#qemu-img create -f qcow2 -o preallocation=metadata $disk ${size}G
# Attach the disk on live guest with persistence
virsh attach-disk $guest $disk $device --cache none --live --persistent
# Detach the disk
#virsh detach-disk $guest $disk --persistent --live
}

check_parameters
add_storage
