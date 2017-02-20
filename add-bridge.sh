#!/bin/bash
# Create an isolated bridge
x=$1
type=$2
bridge="virbr$x"
name=net$x
path=/tmp

isolated () {
cat << EOF > $path/$name.xml
<network>
  <name>$name</name>
  <bridge name='$bridge' stp='on' delay='0'/>
</network>
EOF
}

nat_ipv6 () {
cat << EOF > $path/$name.xml
<network ipv6='yes'>
  <name>$name</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='$bridge' stp='on' delay='0'/>
  <domain name='$name'/>
  <ip address='192.168.10${x}.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.10${x}.128' end='192.168.10${x}.150'/>
    </dhcp>
  </ip>
  <ip family='ipv6' address='fd00:10${x}::1' prefix='64'>
    <dhcp>
      <range start='fd00:10${x}::100' end='fd00:10${x}::1ff'/>
    </dhcp>
  </ip>
</network>
EOF
}

if [ type=isolated ] ; then
    isolated
fi
if [ type=nat ] ; then
    nat_ipv6
fi

virsh net-destroy $name
virsh net-create $path/$name.xml
#virsh net-autostart $name
