#!/bin/bash
sleep 10
sudo waydroid shell -- /system/bin/ip addr add 192.168.240.2/24 dev eth0
sudo waydroid shell -- /system/bin/ip route add default via 192.168.240.1 dev eth0
sudo waydroid shell -- /system/bin/setprop net.dns1 8.8.8.8
sudo waydroid shell -- /system/bin/setprop net.dns2 1.1.1.1
