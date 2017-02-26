#!/bin/bash
#This script attach a live guest NIC to a bridged interface 

guest=$1
bridge=$2
type=bridge
parameters=$#

check_parameters () {
if [ "$parameters" -ne 2  ] ; then
echo "Description : This script attach a live guest to a bridge"
echo "Usage       : $0 <guest name> <bridge_interface_name>"
echo "Example     : $0 guest1 virbr0 attach the live guest1 NIC to virbr0"
exit
fi
if grep -qvw "$guest" <<< $(virsh list --name)  ; then
echo "Please provide a live guest name : exit"
echo "Guests avaible :"
echo "$(virsh list --name)"
exit
fi
#if [ grep -qvw "$bridge" <<< $(virsh net-dumpxml ${bridge}) ] ; then
#echo "This bridge name ${bridge} is not defined"
#echo "Bridges avaible :"
#virsh net-list
#exit
fi
}

attach_nic () {
virsh detach-interface $guest $type --live --persistent
virsh attach-interface $guest --type $type --source $bridge --live --persistent
}

check_parameters
attach_nic

#mac="00:16:3e:1b:f7:47"
#virsh attach-interface $guest --type $type --source $source --mac $mac --live
#
#
##Create an xml file with the definition of your network interface, similar to this example. For example, create a file called hot_net.xml:
#<interface type='bridge'>
#    <source bridge='virbr0'/>
#    <model type='virtio'/>
#</interface>
##Hot plug the interface to the guest with the virsh command. For example, run the following command:
#virsh attach-device guest hot_net.xml
