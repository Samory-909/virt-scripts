# Connect public IPv4 addresses, IPv4 and IPv6 subnets on Hetzner servers

>How can I assign VMs with public ips that I have rented out from ISP (currently Hetzner) ?

https://github.com/goffinet/virt-scripts/issues/4

You can deploy directly your VMs with IP adresses rented from Hetzner for example :

1. assign dynamically to one VM a single public IPv4 address
2. assign dynamically public IPv4 addresses within a subnet to many VMs
3. assign public IPv6 within the default /64 subnet to many VMs

There is two steps for this for procedure, for all cases :

1. Create a connexion (a bridge) with a physical interface ;
2. Connect the VM to this bridge.

In the following example, the virtualization host is rented in a Hetzner DC. The root IPv4/IPv6 addresses are assigned on the `enp2s0` interafce with the `5.9.156.152` value for IPv4 and `2a01:4f8:190:44bb::2/64` for the IPv6 public address. The default IPv6 subnet is `2a01:4f8:190:44bb::/64` with `fe80::1` as default gateway.

## First case : assign dynamically to one VM a single public IPv4 address

A provider like Hetzner can offer one single public IPv4 address linked with a specific MAC address generated. Only the VM using this MAC will get this IPv4 address. In the Hetzner network, a DHCP service attributes the corresponding IP address.

In my case, I obtained `5.9.156.151` linked with the `00:50:56:00:7F:E0` MAC address.

Consider that your guest is called "`guest1`" and that you want add an interface with the generated MAC address to obtain your new single public IP.

First, we create a L2 bridge connected to a physical NIC, the root interface `enp2s0`, this bridge is called `hetzner1`. We use the `add-bridge-l2.sh` to do it with ease :

```
./add-bridge-l2.sh hetzner1 enp2s0
```

In the next step, we attach a new vNIC to our VM with the MAC address from Hetzner, connected on the new bridge `hetzner1` :

```
./add-nic.sh guest1 hetzner1 00:50:56:00:7F:E0
```

The device is succesfully attached :

```
Device attached successfully

 Interface   Type     Source   Model    MAC
-----------------------------------------------------------
 vnet0       bridge   virbr0   virtio   52:54:00:00:ff:40
 macvtap0    direct   enp2s0   virtio   00:50:56:00:7f:e0
```

Inside your guest, the new interface will get the public IP by DHCP.

You can use this connection for IPv6 subnets also (See below).

If you want to deploy a native VM connected on the right bridge with the correct mac address on the first interafce, you can use the `define-guest-image-by-profile.sh` script like this :

```bash
./define-guest-image-by-profile.sh server1 hetzner1 big centos7 00:50:56:00:7F:E0
```

## Second case : assign dynamically public IPv4 addresses within a subnet to many VMs

In the following example, we will create a new router (bridge) that forwards the IPv4 trafic to `5.9.214.208/29` to your server from the Internet and that forwards the trafic from this subnet to the Internet. The router attributes IPv4 adresses (without network and broadcast adresses) :

```
./add-bridge-l3.sh hetzner2 ip4_dhcp 5.9.214.208 255.255.255.248 5.9.156.152
```

And you attach two new guests like `guest2` and `guest3` :

```
for x in 2 3 ; do ./add-nic.sh guest$x hetzner2 ; done
```

## Third case : assign public IPv6 within the default /64 subnet to many VMs

To enable the default IPv6 subnet for your VMs, we simply create a L2 bridge and we attach the VMs. In this example, the root interface is `enp2s0`. The IPv6 range varies between `2a01:4f8:190:44bb::2` and `2a01:4f8:190:44bb:ffff:ffff:ffff:ffff`.

```
./add-bridge-l2.sh ipv6-bridge enp2s0
```

We attach the `guest4` VM to this bridge :

```
./add-nic.sh guest4 ipv6-bridge
```

In this case, we must configure manually the IPv6 connexion inside our VMs, for example :

```
ip -6 add add 2a01:4f8:190:44bb::0100/64 dev eth1
ip -6 route add default via fe80::1 dev eth1
```
