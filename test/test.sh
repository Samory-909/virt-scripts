#!/bin/bash

os="$1"
version="$2"
date=$(date +%s)
action="$3"

image_build () {
./auto-install.sh ${os} ${os}
du -h /var/lib/libvirt/images/${os}.qcow2
sleep 30
virsh destroy ${os}
}

image_provision () {
sleep 1
}


image_install () {
./sparsify.sh ${os}
du -h /var/lib/libvirt/images/${os}.qcow2
virsh undefine ${os}
mv /var/lib/libvirt/images/${os}.qcow2 /var/lib/libvirt/images/${os}${version}.qcow2
du -h /var/lib/libvirt/images/${os}${version}.qcow2
}

guests_launch () {
for x in {1..5} ; do ./define-guest-image.sh ${os}-$x ${os}${version} ; sleep 45 ; done &&
./hosts-file.sh >> /etc/hosts
}

guests_icmp_echo () {
for x in {1..5} ; do ping -c1 ${os}-$x >> /tmp/${date}-${os}${version}.log ; done
echo "Logs in /tmp/virt-scripts-${os}${version}-${date}.log"
}

guests_erase () {
./destroy_and_undefine_all.sh
sed -if "/$os-/d" /etc/hosts
}

if [ -z "${action}" ] ; then
  echo "script error" ; exit
else
	if grep -q 'b' <<< "${action}" ; then
		image_build
		if [ !-f /var/lib/libvirt/images/${os}.qcow2 ] ; then echo "script error" ; exit ; fi
	fi
	if grep -q 'p' <<< "${action}" ; then
	  image_provision
	fi
	if grep -q 'i' <<< "${action}" ; then
		image_install
		if [ !-f /var/lib/libvirt/images/${os}${version}.qcow2 ] ; then echo "script error" ; exit ; fi
	fi
	if grep -q 't' <<< "${action}" ; then
		guests_icmp_echo
	  guests_erase
	fi
else
	echo "script error" ; exit
fi