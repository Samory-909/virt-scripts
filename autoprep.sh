#!/bin/bash

echo " Upgrade the system"
sudo yum -y upgrade
echo "Virtualization host installation"
sudo yum -y group install "Virtualization Host"
echo "Virtualisation tools installation"
sudo yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer
echo "Activate all those services"
sudo systemctl stop firewalld
sudo systemctl restart libvirtd
sudo systemctl restart httpd
sudo virt-host-validate
