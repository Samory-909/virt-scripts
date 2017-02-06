#!/bin/bash

guest=$1
type=bridge
source=virbr3
virsh detach-interface $guest $type --live --persistent
virsh attach-interface $guest --type $type --source $source --live --persistent
#
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
