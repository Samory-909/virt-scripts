#!/bin/bash
# Variables
guest=$1
disk=/var/lib/libvirt/images/${1}-${2}.img
size=$3
seek=$[${size}*1024]
# Create Spare Disk with dd
dd if=/dev/zero of=$disk  bs=1M seek=$seek count=0
# Or create a qcow2 disk
#qemu-img create -f qcow2 -o preallocation=metadata $disk ${size}G
# Attach the disk on live guest with persistence
virsh attach-disk $guest $disk $2 --cache none --live --persistent
# Detach the disk
#virsh detach-disk $guest $disk --persistent --live
