#!/bin/bash
# This script create an isolated or a nat/ipv6 bridge <name> <type>
name=${1}
bridge=$name
# 'isolated' or 'nat'
type=${2}
parameters=$#
path="/tmp"
net_id1="$(shuf -i 0-255 -n 1)"
net_id2="$(shuf -i 0-255 -n 1)"
# random /24 in 10.0.0.0/8 range
ip4="10.${net_id1}.${net_id2}."
ip6="fd00:${net_id1}:${net_id2}::"
# Fix your own range
#ip4="192.168.1."
#ip6="fd00:1::"

check_parameters () {
if [ "$parameters" -ne 2  ] ; then
echo "Description : This script create an isolated or a nat/ipv6 bridge" 
echo "Usage       : $0 <name> <type, isolated or nat>"
echo "Example     : '$0 net1 isolated' or '$0 lan101 nat'"
exit
fi
}

check_bridge_name () {
if [ -e /run/libvirt/network/${name}.xml ] ; then
echo "This bridge name ${name} is already in use"
echo "Change the bridge name or do 'virsh net-destroy ${name}' : exit"
exit
fi
}

check_interface () {
if [ -z "${bridge}" ]; then
echo "Please provide a valid interface name : exit"
exit
fi
intlist=$(echo $(ls /sys/class/net))
for interface in ${intlist} ; do
if [ ${interface} = ${bridge} ] ; then
echo "This interface ${bridge} is already in use"
echo "Please provide an other bridged interface name : exit"
exit
fi
done
}

validate_ip_range () {
check_ip4 () {
ip4list=$(echo $(ip -4 route | awk '{ print $1; }' | sed 's/\/.*$//'))
for ip4int in ${ip4list} ; do
if [ ${ip4int} = ${ip4} ] ; then
echo "Random Error, Please retry $@ : exit"
exit
fi
done
}
check_ip6 () {
ip6list=$(echo $(ip -6 route | awk '{ print $1; }' | sed 's/\/.*$//'))
for ip6int in ${ip6list} ; do
if [ ${ip6int} = ${ip6} ] ; then
echo "Random Error, Please retry $@ : exit"
exit
fi
done
}
check_ip4
check_ip6
}

isolated () {
cat << EOF > ${path}/${name}.xml
<network>
  <name>${name}</name>
  <bridge name='${bridge}' stp='on' delay='0'/>
</network>
EOF
}

nat_ipv6 () {
cat << EOF > ${path}/${name}.xml
<network ipv6='yes'>
  <name>${name}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='${bridge}' stp='on' delay='0'/>
  <domain name='${name}'/>
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
cat << EOF > ~/${name}_report.txt
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
echo "~/${name}_report.txt writed : "
cat ~/${name}_report.txt
}

check_type () {
case ${type} in
    isolated) isolated ;;
    nat) nat_ipv6 ; report_nat_ipv6 ;;
    *) echo "isolated or nat ? exit" ; exit ;;
esac
}

create_bridge () {
#cat ${path}/${name}.xml
virsh net-destroy ${name}
virsh net-create ${path}/${name}.xml
#virsh net-autostart ${name}
}

check_parameters
validate_ip_range
check_bridge_name
check_interface
check_type
create_bridge
virsh net-list
