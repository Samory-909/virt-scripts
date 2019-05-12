#!/bin/bash

./auto-install.sh centos centos
du -h /var/lib/libvirt/images/centos.qcow2
./sparsify.sh centos
virsh undefine centos
mv /var/lib/libvirt/images/centos.qcow2 /var/lib/libvirt/images/centos7.qcow2
du -h /var/lib/libvirt/images/centos7.qcow2
