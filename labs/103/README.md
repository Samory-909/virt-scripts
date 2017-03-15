# Lab103 : OSPF quad pod

## Topology

```
    +---+                              +---+
    |PC1|            ***************   |PC2|
    +---+            *10.103.2.0/24*   +---+
   +---+             ***************  +---+
      |                                  |
      | ***************                  |
      | *10.103.1.0/24*                  |
      | ***************                  |
      |                                  |
      |.1/24                        .2/24|
+----------+                       +----------+
|   eth0   |                       |   eth0   |
|          |                       |          |
|    R1    |                       |    R2    |
|          |                       |          |
|   eth1   |                       |   eth1   |
+----------+                       +----+-----+
     |.1/24     ***************         |
     |          *10.103.0.0/24*         |
     |          ***************         |
     |                                  |
     |           +----------+           |
     +-----------+          +-----------+
                 |WAN SWITCH|
     +-----------+          +-----------+
     |           +----------+           |
     |                                  |
     |                                  |
     |                                  |
     |                                  |
     |.3/24                        .4/24|
+----------+                       +----------+
|   eth1   |                       |   eth1   |
|          |                       |          |
|    R3    |                       |    R4    |
|          |                       |          |
|   eth0   |                       |   eth0   |
+----+-----+                       +----+-----+
     |                                  |
     | ***************                  |
     | *10.103.3.0/24*                  |
     | ***************                  |
     |                                  |
   +-+-+         ***************      +-+-+
   |PC3|         *10.103.4.0/24*      |PC4|
   +---+         ***************      +---+
  +---+                              +---+
```


## Routing table on r2-103

```
[root@r2-103 ~]# vtysh

Hello, this is Quagga (version 0.99.22.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

r2-103# sh ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, A - Babel,
       > - selected route, * - FIB route

K * 0.0.0.0/0 via 192.168.122.1, eth2 inactive
O   10.103.0.0/24 [110/10] is directly connected, eth1, 00:00:56
C>* 10.103.0.0/24 is directly connected, eth1
O>* 10.103.1.0/24 [110/20] via 10.103.0.1, eth1, 00:00:56
O   10.103.2.0/24 [110/10] is directly connected, eth0, 00:02:16
C>* 10.103.2.0/24 is directly connected, eth0
O>* 10.103.3.0/24 [110/20] via 10.103.0.3, eth1, 00:00:56
O>* 10.103.4.0/24 [110/20] via 10.103.0.4, eth1, 00:00:56
C>* 127.0.0.0/8 is directly connected, lo
r2-103# exit
```


## End to end connectivity from one of routers to each end PC

```
for id in 1 2 3 4 ; do
if [ -z /root/.ssh/id_rsa.pub ] ; then
ssh-keygen -q ; fi
ssh-copy-id 10.103.0.${id}
done
for id in 1 2 3 4 ; do
echo "R${id} --> PC${id}"
ping -c1 $(ssh 10.103.0.${id} "cat /var/lib/dnsmasq/dnsmasq.leases | grep pc | cut -d ' ' -f 3")
done
```

## End to end connectivity from one PC to each LAN gateway interface

```
for id in 1 2 3 4 ; do
echo "PC${id} -->  LAN${id}"
ping -c1 10.103.${id}.1
done
```

