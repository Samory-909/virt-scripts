#!/bin/bash

# Variables
guest=$1
disk=/var/lib/libvirt/images/$2.img
device=$3
#device=vdb

# Create 4G Spare Disk with dd
dd if=/dev/zero of=$disk  bs=1M seek=4096 count=0
# Or create a qcow2 disk
qemu-img create -f qcow2 -o preallocation=metadata $disk 4G
# Attach the disk on live guest with persistence
virsh attach-disk $guest $disk $device --cache none --live --persistent
# Detach the disk
virsh detach-disk $guest $disk --persistent --live
