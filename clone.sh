#!/bin/bash
#This script clone, sparsify and sysprep linux guest
original=$1
destination=$2
name=$original

check_guest_name () {
if [ -z "${name}" ]; then
echo "This script clones, sparsifies and syspreps linux guest"
echo "Usage : '$0 <original guest> <destination guest>'"
echo "Please provide a the guest name of a destroyed guest: exit"
exit
fi
if grep -qv ${name} <<< $(virsh list --all --name)  ; then
echo "Please provide a defined guest name : exit"
echo "Guests avaible : $(virsh list --all --name)"
exit
fi
}

check_destination () {
if [ -z $destination ] ; then
echo "Please provide the name of the destination guest: exit"
echo "For example : '$0 $name <destination guest>'"
exit
fi
}

sparsify () {
virt-clone -o $original -n $destination -f /var/lib/libvirt/images/$destination.qcow2
echo "Sparse disk optimization"
virt-sparsify --check-tmpdir ignore --compress --convert qcow2 --format qcow2 /var/lib/libvirt/images/$destination.qcow2 /var/lib/libvirt/images/$destination.sparse
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

check_guest_name
check_destination
sparsify
prepare
