#!/bin/bash
#This script attach a guest NIC to a bridged interface

guest=$1
bridge=$2
type=bridge

check_parameters () {
if [ "$#" -ne 2  ] ; then
echo "Description : This script attach a guest NIC to a bridged interface"
echo "Usage       : $0 <guest name> <bridge_interface>"
echo "Example     : $0 guest1 virbr0 attach the guest1 NIC to virbr0"
exit
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
