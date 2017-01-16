#!/bin/bash

original=$1
destination=$2

sparsify () {
virt-clone -o $original -n $destination -f /var/lib/libvirt/images/$destination.qcow2
echo "Sparse disk optimization"
virt-sparsify --check-tmpdir=ignore --compress --convert qcow2 --format qcow2 /var/lib/libvirt/images/$destination.qcow2 /var/lib/libvirt/images/$destination.sparse
rm -rf /var/lib/libvirt/images/$destination.qcow2
mv /var/lib/libvirt/images/$destination.sparse /var/lib/libvirt/images/$destination.qcow2
chown qemu:qemu /var/lib/libvirt/images/$destination.qcow2
}

prepare () {
virt-sysprep --operations -ssh-hostkeys --format=qcow2 -a /var/lib/libvirt/images/$destination.qcow2
#virt-edit $destination /etc/passwd -e 's/^root:.*?:/root::/'
guestfish -a /var/lib/libvirt/images/$destination.qcow2 -i <<EOF
write /etc/hostname "$destination\n"
EOF
#write-append /etc/sysconfig/network-scripts/ifcfg-eth0 "DHCP_HOSTNAME=$domain\nHWADDR=$mac\n"
}

sparsify
prepare
