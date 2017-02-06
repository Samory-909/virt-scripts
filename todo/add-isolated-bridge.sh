#!/bin/bash
# Create an isolated bridge

bridge="virbr3"
name=lan
path=/tmp
cat << EOF > $path/$name.xml
<network>
  <name>$name</name>
  <bridge name='$virbr3' stp='on' delay='0'/>
</network>
EOF

virsh net-destroy $name
virsh net-create $path/$name.xml
virsh net-autostart $name
