#!/bin/bash
#This script attach a disk to a live guest
guest=$1
disk=/var/lib/libvirt/images/${1}-${2}.img
size=$3

check_parameters () {
if [ "$#" -ne 3  ] ; then
echo "Description : This script attach a disk to a live guest"
echo "Usage       : $0 <guest name> <block device name> <size in GB>"
echo "Example     : '$0 guest1 vdb 4' add a vdb disk to guest1"
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
virsh attach-disk $guest $disk $2 --cache none --live --persistent
# Detach the disk
#virsh detach-disk $guest $disk --persistent --live
}

check_parameters
add_storage
