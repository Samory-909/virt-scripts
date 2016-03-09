#!/bin/bash

mirror=/var/lib/iso/CentOS-7-x86_64-DVD-1511.iso

virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.qcow2,size=5,format=qcow2 \
--ram=1024 \
--vcpus=1 \
--os-variant=rhel7 \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "console=ttyS0,115200n8 serial"
