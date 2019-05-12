#!/bin/bash

os="$1"
version="$2"

# Deploy and test guests
for x in {1..5} ; do ./define-guest-image.sh ${os}-$x ${os}${version} ; done && \
sleep 180 && \
./hosts-file.sh >> /etc/hosts && \
for x in {1..5} ; do ping -c1 ${os}-$x ; done

# Erase all

./destroy_and_undefine_all.sh
sed -if "/$os-/d" /etc/hosts
