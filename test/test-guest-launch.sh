#!/bin/bash

os="$1"
version="$2"
date=$(date +%s)


# Deploy and test guests
for x in {1..5} ; do ./define-guest-image.sh ${os}-$x ${os}${version} ; sleep 45 ; done &&
./hosts-file.sh >> /etc/hosts && \
for x in {1..5} ; do ping -c1 ${os}-$x >> /tmp/${date}-${os}${version}.log ; done
echo "Logs in /tmp/virt-scripts-${os}${version}-${date}.log"

# Erase all

./destroy_and_undefine_all.sh
sed -if "/$os-/d" /etc/hosts
