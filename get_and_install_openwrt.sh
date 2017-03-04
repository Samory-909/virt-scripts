#!/bin/bash
## OpenWRT 15.05 router Firewall with two interfaces
# Fix variables
name=$1
url=https://downloads.openwrt.org/chaos_calmer/15.05/x86/kvm_guest/openwrt-15.05-x86-kvm_guest-combined-ext4.img.gz
destination=/var/lib/libvirt/images/
parameters=$#

check_parameters () {
# Check parameters
if [ $parameters -ne 1 ]; then
echo "Please provide the name" ; exit
exit
fi
# Check the name
if grep -qw ${name} <<< $(virsh list --all --name)  ; then
echo "Please provide a guest name that is not in use : exit"
exit
fi
}

bridges_creation () {
# bridges creation
./add-bridge.sh lan-$name isolated
./add-bridge.sh internet-$name nat
}

openwrt_installation () {
# Get and decompresse image
wget $url$image -O $destination$name.img.gz
gunzip $destination$name.img.gz
# Install the guest
virt-install --name=$name \
--ram=128 --vcpus=1 \
--os-type=linux \
--disk path=$destination$name.img,bus=ide \
--network bridge=lan-$name,model=virtio \
--network bridge=internet-$name,model=virtio \
--import  \
--noautoconsole
}

check_parameters
bridges_creation
openwrt_installation
