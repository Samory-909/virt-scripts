#!/bin/bash

# Variables
guest=$1
disk=/var/lib/libvirt/images/$1-$2.img
device=$2
#device=vdb

# Create 4G Spare Disk with dd
dd if=/dev/zero of=$disk  bs=1M seek=4096 count=0
# Or create a qcow2 disk with qemu-img
#qemu-img create -f qcow2 -o preallocation=metadata $disk 4G
# Or create a qcow2 disk with libvirt
#virsh vol-create-as default $2.img --capacity 4G --format qcow2 --prealloc-metadata
# Attach the disk on live guest with persistence
virsh attach-disk $guest $disk $device --cache none --live --persistent
# Detach the disk
#virsh detach-disk $guest $disk --persistent --live
