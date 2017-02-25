#!/bin/bash
# Create an isolated or a nat/ipv6 bridge <name> <interface> <type>
name=$1
bridge=$2
# 'isolated' or 'nat'
type=$3
path=/tmp
net_id1="$(shuf -i 0-255 -n 1)"
net_id2="$(shuf -i 0-255 -n 1)"
# random /24 in 10.0.0.0/8 range
ip4="10.${net_id1}.${net_id2}."
ip6="fd00:${net_id1}:${net_id2}::"
# Fix your own range
#ip4="192.168.1."
#ip6="fd00:1::"

check_name () {
if [ -e /run/libvirt/network/$name.xml ] ; then
echo "Used name : exit."
echo "change the bridge name or do 'virsh net-destroy $name'"
exit
fi
#echo OK
}

check_interface () {
intlist=$(echo $(ls /sys/class/net))
for x in $intlist ; do
if [ $x = $bridge ] ; then
echo "Used interface : exit"
echo "change the bridge interface $bridge"
exit
fi
done
#echo OK
}

validate_ip_range () {

check_ip4 () {
iplist=$(echo $(ip -4 route | awk '{ print $1; }' | sed 's/\/.*$//'))
for ipint in $iplist ; do
if [ $ipint = ${ip4} ] ; then
echo Random Error
exit
fi
done
}

check_ip6 () {
iplist=$(echo $(ip -6 route | awk '{ print $1; }' | sed 's/\/.*$//'))
for ipint in $iplist ; do
if [ $ipint = $ip6 ] ; then
echo Random Error
exit
fi
done
}

check_ip4
check_ip6

}


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
  <ip address='${ip4}1' netmask='255.255.255.0'>
    <dhcp>
      <range start='${ip4}128' end='${ip4}150'/>
    </dhcp>
  </ip>
  <ip family='ipv6' address='${ip6}1' prefix='64'>
    <dhcp>
      <range start='${ip6}100' end='${ip6}1ff'/>
    </dhcp>
  </ip>
</network>
EOF
}

report_nat_ipv6 () {
cat << EOF > ~/$name_report.txt
Bridge Name         : $name
Bridge Interface    : $bridge
------------------------------------------------------------
Bridge IPv4 address : ${ip4}1/24
IPv4 range          : ${ip4}0 255.255.255.0
DHCP range          : ${ip4}128 - ${ip4}150
Bridge IPv6 address : ${ip6}1
IPv6 range          : ${ip6}::/64
DHCPv6 range        : ${ip6}128/24 - ${ip4}150/24
EOF
echo "~/$name_report.txt writed : "
cat ~/$name_report.txt
}

check_type () {
case $type in
    isolated) isolated ;;
    nat) nat_ipv6 ; report_nat_ipv6 ;;
    *) echo "isolated or nat ? exit" ;;
esac
}

create_bridge () {
#cat $path/$name.xml
virsh net-destroy $name
virsh net-create $path/$name.xml
#virsh net-autostart $name
}

validate_ip_range
check_name
check_interface
check_type
create_bridge
virsh net-list
