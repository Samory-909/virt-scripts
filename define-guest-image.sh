#!/bin/bash
## This script import and launch minimal KVM images with a text console ##
## First download all the qcow2 images on https://get.goffinet.org/kvm/ ##
## Usage : bash define-guest.sh <name> <image> ##
## Reset root password with the procedure : ##
## https://linux.goffinet.org/processus_et_demarrage.html#10-password-recovery  ##
## Please check all the variables ##
# First parmater as name
name=$1
# Secund parameter image name avaible on "https://get.goffinet.org/kvm/"
# Image name : 'debian7', 'debian8', 'centos7', 'ubuntu1604', 'metasploitable', kali
image="$2.qcow2"
# Generate an unique string
uuid=$(uuidgen -t)
# VCPUs
vcpu="1"
# The new guest disk name
disk="${name}-${uuid:25}.qcow2"
# Diskbus can be 'ide', 'scsi', 'usb', 'virtio' or 'xen'
diskbus="virtio"
size="8"
# Hypervisor can be 'qemu', 'kvm' or 'xen'
hypervisor="kvm"
# RAM in Mb
memory="256"
# Graphics 'none' or 'vnc'
graphics="none"
# Network inetrface and model 'virtio' or 'rtl8139' or 'e1000'
interface="virbr0"
model="virtio"
# Parameters for metasploitable guests
if [ $image = "metasploitable.qcow2" ]; then
diskbus="scsi"
memory="512"
model="e1000"
fi
# Parameters for Kali guests
if [ $image = "kali.qcow2" ]; then
memory="1024"
size="16"
fi
## Local image copy to the default storage pool ##
cp ./$image /var/lib/libvirt/images/$disk
## Import and lauch the new guest ##
virt-install \
--virt-type $hypervisor \
--name=$name \
--disk path=/var/lib/libvirt/images/$disk,size=$size,format=qcow2,bus=$diskbus \
--ram=$memory \
--vcpus=$vcpu \
--os-variant=linux \
--network bridge=$interface,model=$model \
--graphics $graphics \
--console pty,target_type=serial \
--import \
--noautoconsole