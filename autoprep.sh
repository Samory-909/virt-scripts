#!/bin/bash


debian8_prep() {
echo " Upgrade the system"
sudo apt-get update && sudo apt-get -y upgrade
echo "Virtualization host installation"
sudo apt-get -y install qemu-kvm libvirt-bin virtinst virt-viewer libguestfs-tools
}

centos7_prep() { 
echo " Upgrade the system"
sudo yum -y upgrade
echo "Virtualization host installation"
sudo yum -y group install "Virtualization Host"
sudo yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer
}

services_activation() {
echo "Activate all those services"
sudo systemctl stop firewalld
sudo systemctl restart libvirtd
sudo systemctl restart httpd
sudo virt-host-validate
}

if [ -f /etc/debian_version ]; then
debian8_prep
sudo virsh net-start default
sudo virsh net-autostart default
services_activation
elif [ -f /etc/redhat-release ]; then
centos7_prep
services_activation
fi
