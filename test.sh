#!/bin/bash

os="$1"
version="$2"

virsh undefine ${os} --remove-all-storage || \
./auto-install.sh ${os} ${os} && ./sparsify.sh ${os} && \
virsh undefine ${os} && \
mv /var/lib/libvirt/images/${os}.qcow2 /var/lib/libvirt/images/${os}1804.qcow2 && \
for x in {1..5} ; do ./define-guest-image.sh ubu-$x ${os}1804 ; done && \
sleep 90 && \
./hosts-file.sh >> /etc/hosts && \
for x in {1..5} ; do ping -c1 ${os}-$x ; done
