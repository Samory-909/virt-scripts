#!/bin/bash

echo "127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4" #> /etc/hosts
echo "::1 localhost localhost.localdomain localhost6 localhost6.localdomain6" #>> /etc/hosts
for name in $(virsh list --name); do
mac=$(virsh dumpxml ${name}|grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g")
ip=$(grep $mac /var/log/messages | tail -n 1 | awk '{print $7}')
echo "$ip $name" #>> /etc/hosts
done
