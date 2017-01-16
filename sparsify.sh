#!/bin/bash

name=$1

sparsify ()
{
echo "stop guest OS"
virsh destroy $name
echo "Sparse disk optimization"
# make a virtual machine disk sparse
virt-sparsify --check-tmpdir=ignore --compress --convert qcow2 --format qcow2 /var/lib/libvirt/images/$name.qcow2 /var/lib/libvirt/images/$name-sparsified.qcow2
# remove original image
rm -rf /var/lib/libvirt/images/$name.qcow2
# rename sparsified
mv /var/lib/libvirt/images/$name-sparsified.qcow2 /var/lib/libvirt/images/$name.qcow2
# set correct ownership for the VM image file
chown qemu:qemu /var/lib/libvirt/images/$name.qcow2
}

sparsify
