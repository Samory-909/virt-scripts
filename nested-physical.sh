#!/bin/bash
#This script enable nested virtualization on the physical host
echo "Description : This script attach a guest NIC to a bridged interface"
rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
modprobe kvm-intel
cat /sys/module/kvm_intel/parameters/nested
