#!/bin/bash

os="$1"
version="$2"
date=$(date +%s)
action="$3"
wd="$PWD"
silent="> /dev/null 2>&1"

image_build () {
echo "#########################################################################"
echo "#  Image Build                                                          #"
echo "#########################################################################"
cd ${wd}
./auto-install.sh ${os} ${os}
du -h /var/lib/libvirt/images/${os}.qcow2
sleep 30
virsh destroy ${os}
}

image_provision () {
echo "#########################################################################"
echo "#  Image Provision                                                      #"
echo "#########################################################################"
which curl || apt -y install curl
which ansible || ( curl -L https://git.io/fjWan -o install-ansible.sh && bash -x install-ansible.sh )
sed -i '1 i\nameserver 192.168.122.1' /etc/resolv.conf
ssh-keygen -f "/root/.ssh/known_hosts" -R "${os}"
virsh start ${os}
cd cd ${wd}ansible
#ansible -m ping -i inventory ${os} && \
ansible-playbook -i inventory playbook.yml --limit ${os}
cd ${wd}
virsh destroy ${os}
sed -if "/nameserver 192.168.122.1/d" /etc/resolv.conf
ssh-keygen -f "/root/.ssh/known_hosts" -R "${os}"
}


image_install () {
echo "#########################################################################"
echo "#  Image Installation                                                   #"
echo "#########################################################################"
du -h /var/lib/libvirt/images/${os}.qcow2
cd ${wd}
./sparsify.sh ${os}
virsh undefine ${os}
mv /var/lib/libvirt/images/${os}.qcow2 /var/lib/libvirt/images/${os}${version}.qcow2
du -h /var/lib/libvirt/images/${os}${version}.qcow2
}

guests_launch () {
echo "#########################################################################"
echo "#  Launch 5 guests                                                      #"
echo "#########################################################################"
cd ${wd}
for x in {1..5} ; do ./define-guest-image.sh ${os}-$x ${os}${version} ; done
sleep 180
./hosts-file.sh >> /etc/hosts
}

guests_icmp_echo () {
echo "#########################################################################"
echo "#  ICMP echo Req against the 5 guests                                   #"
echo "#########################################################################"
for x in {1..5} ; do ping -c1 ${os}-$x ; done
echo "Logs in /tmp/virt-scripts-${os}${version}-${date}.log"
}

guests_erase () {
echo "#########################################################################"
echo "#  Erase the 5 guests                                                   #"
echo "#########################################################################"
for x in {1..5} ; do
virsh destroy ${os}-${x}
virsh undefine ${os}-${x} --remove-all-storage
sed -if "/$os-$x/d" /etc/hosts
done
}

if [ -z "${action}" ] ; then
  echo "script error" ; exit
else
	if grep -q 'b' <<< "${action}" ; then
		image_build ${silent}
		if [ ! -f /var/lib/libvirt/images/${os}.qcow2 ] ; then echo "script error" ; exit ; fi
	fi
	if grep -q 'p' <<< "${action}" ; then
	  image_provision ${silent}
	fi
	if grep -q 'i' <<< "${action}" ; then
		image_install ${silent}
		if [ ! -f /var/lib/libvirt/images/${os}${version}.qcow2 ] ; then echo "script error" ; exit ; fi
	fi
	if grep -q 't' <<< "${action}" ; then
    guests_launch ${silent}
		guests_icmp_echo
	  guests_erase ${silent}
	fi
fi
