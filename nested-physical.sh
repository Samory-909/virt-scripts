#!/bin/bash

rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
modprobe kvm-intel
cat /sys/module/kvm_intel/parameters/nested
