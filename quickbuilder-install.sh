#!/bin/bash

mkdir quickbuilder
cd quickbuilder
wget  https://gist.githubusercontent.com/goffinet/65c5ecc452474dfc106b3edebe9a93c6/raw/721952f8f764c2b8ef6116c16d2eba89270a9ddf/define-guest.sh
for x in centos7.qcow2 debian7.qcow2 debian8.qcow2 ubuntu1604.qcow2; do wget http://get.goffinet.org/kvm/$x; done
