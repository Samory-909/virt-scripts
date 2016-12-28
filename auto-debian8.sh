#!/bin/bash

mirror=http://debian.mirrors.ovh.net/debian/dists/jessie/main/installer-amd64/

virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.qcow2,size=8,format=qcow2 \
--ram=512 \
--vcpus=1 \
--os-variant=debian8 \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "auto=true hostname=$1 domain=  url=http://192.168.122.1/conf/debian8-preseed.cfg text console=ttyS0,115200n8 serial"
