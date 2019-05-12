#!/bin/bash

os="$1"
version="$2"

./auto-install.sh ${os} ${os}
du -h /var/lib/libvirt/images/${os}.qcow2
./sparsify.sh ${os}
virsh undefine ${os}
mv /var/lib/libvirt/images/${os}.qcow2 /var/lib/libvirt/images/${os}${version}.qcow2
du -h /var/lib/libvirt/images/${os}${version}.qcow2
