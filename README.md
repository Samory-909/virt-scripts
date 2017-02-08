# Virt-scripts

This suite of "quick and dirty" scripts are intended to mount virtual sandboxes for labs during Linux training courses with KVM/libvirtd with Centos 7 or Debian Jessie hosts. 
The main goal is to have on hand the major distributions by exploiting the Linux environment as well as possible. But we can find other subsequents objectives as programmation and automation, scripting and virtual network and system management. At this moment, you will not find any error management as we suppose a Centos 7 or a Debian Jessie standard installation on the virtualization host.

## Contents

The main scripts are :

1. `autoprep.sh` : prepare your system as virtualization host
* `get-iso.sh` : get iso distributions
* `auto-install.sh` : build a fresh Centos, Debian or Ubuntu system with http repos and kickstart files
* `sparsify.sh` : optimize space disk on the designated guest
* `clone.sh` : clone, sysprep and optimize builded guests
* `hosts-file` : print the running guests and their ipv4 address

## New scripts

The name explains the function.

### Add bridge, vnic, disk

1. `add-isolated-bridge.sh` : add an isolated libvirt bridge
* `add-net-live.sh` : attach a bridged network interface to a live guest
* `add-storage.sh` : attach an empty bit disk by Gb size

### Guests installations and deployments

1. `auto-install-tui.sh` : auto-install.sh text user interface demo
* `nested-physical.sh` : nested installation
* `quickbuilder-install.sh` : install quickbuilder procedure
* `define-guest-image.sh` : Install pre-buid images (quickbuilder)
* `get_and_install_openwrt.sh` : get and start openwrt with two interfaces

### Start stop  and remove guests

1. `start_all.sh` : start all the defined guests
* `destroy_and_undefine_all.sh` : destroy,  undefine all the guests with storage removing

## Lab scripts

### Step 1 : Verify your installation

Script : autoprep.sh

Description : Setup KVM/Libvirtd/LibguestFS on RHEL7/Centos 7/Debian Jessie.

Usage : 

```
# ./autoprep.sh
```

### Step 2 : Get iso images (optionnal)

Script : get-iso.sh

Description : Get latest iso of Centos 7, Debian Jessie and Ubuntu Xenial.

Usage :

```
# ./get-iso.sh unknow
Erreur dans le script : ./get-iso.sh [ centos | debian | ubuntu ]
```

### Step 3 : Build a guest automatically

Script : auto-install.sh 

Description :  Centos 7, Debian Jessie or Ubuntu Xenial fully automatic installation by HTTP Repo and response file via local HTTP.

Usage :

```
./auto-install.sh [ centos | debian | ubuntu ] guest_name
```

Note : Escape character is `^]`


### Step 4 : Sparse your native image

Script : sparsify.sh

Description : Sparse a disk. Great gain on disk space !

Usage :

```
./sparsify.sh guest_name
```

Check the disk usage : 2,0G

```
# du -h /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
2,0G    /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
```

Sparsify operation

```
# ./sparsify.sh ubuntu-gold-31122016

Sparse disk optimization
[   0,1] Create overlay file in /tmp to protect source disk
[   0,1] Examine source disk
[   4,3] Fill free space in /dev/sda1 with zero
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ --:--
[   6,9] Fill free space in /dev/u1-vg/root with zero
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ 00:00
[  70,6] Clearing Linux swap on /dev/u1-vg/swap_1
[  71,9] Copy to destination and make sparse
[ 191,4] Sparsify operation completed with no errors.
virt-sparsify: Before deleting the old disk, carefully check that the
target disk boots and works correctly.
```

Check the disk usage : 432M


```
# du -h /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
432M    /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
```

### Step 5 : Clone your guest

Script : clone.sh

Description : Cloning a domain disk with sparsifying and Linux sysprep.

Usage :

```
./clone.sh original_guest_name clone_guest_name
```

### Step 6 : Add the guest hostname resolution

Script : 

Description : Print a new `/etc/resolv.conf` with the ip address and the hostname of running guests.

Usage :

```
./hosts-file.sh
```

For example :

```
# ./hosts-file.sh
192.168.122.152 d1
192.168.122.236 d2
192.168.122.190 d3
192.168.122.155 c1
192.168.122.100 c2
192.168.122.40 c3
```

To update your `/etc/hosts` :

```
./hosts-file.sh >> /etc/hosts
```

### Next steps ...

* Install ansible, add ssh hosts keys, create an ansible inventory and test your managed nodes.
* Add dynamicaly a new disk.
* Create a guest as router/firewall and migrate your VM to another virtual switch.
* Exploit Nested virtualization
* Exploit snapshots and virtual storage

## Todo

* `auto-install.sh` :
 * bridge variable
 * strorage choice
 * Other distros :
  * Fedora
  * Arch Linux
  * Kali without GDM

* `add-storage.sh` : add hot virtio disk 

* `add-interface.sh` : push new eth interface with preconfig

* `start_all.sh` and `destroy_all.sh` : get domains, give choices and stop/start

* `create_repo.sh` : create local repo
