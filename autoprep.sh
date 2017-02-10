#!/bin/bash


debian8_prep() {
echo " Upgrade the system"
apt-get -y install sudo
sudo apt-get update && sudo apt-get -y upgrade
echo "Virtualization host installation"
sudo apt-get -y install qemu-kvm libvirt-bin virtinst virt-viewer libguestfs-tools virt-manager uuid-runtime
}

centos7_prep() { 
echo " Upgrade the system"
sudo yum -y upgrade
echo "Virtualization host installation"
sudo yum -y group install "Virtualization Host"
sudo yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer virt-manager
}

services_activation() {
echo "Activate all those services"
sudo systemctl stop firewalld
sudo systemctl restart libvirtd
sudo virt-host-validate
}

check_apache () {
yum install -y httpd curl || apt-get -y install apache2 curl
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd || systemctl enable apache2
systemctl start httpd || systemctl start apache2
mkdir -p /var/www/html/conf
echo "this is ok" > /var/www/html/conf/ok
local check_value="this is ok"
local check_remote=$(curl -s http://127.0.0.1/conf/ok)
if [ "$check_remote"="$check_value" ] ; then
 echo "Apache is working"
else
 echo "Apache is not working"
 exit
fi
}

if [ -f /etc/debian_version ]; then
debian8_prep
sudo virsh net-start default
sudo virsh net-autostart default
elif [ -f /etc/redhat-release ]; then
centos7_prep
fi
services_activation
check_apache
