#!/bin/bash
##Router Firewall with two interfaces
## WAN interface is default KVM bridge virbr0
##Create an isloted bridge named LAN on virbr3 with this xml file :
#<network>
#  <name>LAN</name>
#  <bridge name='virbr3' stp='on' delay='0'/>
#</network>
##Enable the bridge :
#virsh net-start LAN
#virsh net-autostart LAN
#
name=$1
url=https://downloads.openwrt.org/chaos_calmer/15.05/x86/kvm_guest/openwrt-15.05-x86-kvm_guest-combined-ext4.img.gz
destination=/var/lib/libvirt/images/
if [ $# -lt 1 ]; then
echo "Please provide the VM name" ; exit
else
wget $url$image -O $destination$name.img.gz
gunzip $destination$name.img.gz
virt-install --name=$name \
--ram=256 --vcpus=1 \
--os-type=linux \
--disk path=$destination$name.img,bus=ide \
--network bridge=virbr3,model=virtio \
--network bridge=virbr0,model=virtio \
--import & > /dev/null
sleep 5
kill $(ps aux | grep virt-install | head -n 1 | awk '{ print $2 }')

fi
