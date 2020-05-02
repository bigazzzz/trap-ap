#!/bin/sh
WIFI_IFACE=wpl2s0
ETH_IFACE=enp3s0
sudo apt update
sudo apt install hostapd dnsmasq
sudo cp dnsmasq.conf.small /etc/dnsmasq.conf
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -tnat -A POSTROUTING -o $ETH_IFACE -j MASQUERADE
sudo echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo echo nameserver 8.8.4.4 >> /etc/resolv.conf
sudo ip addr add 192.168.2.1/24 dev $WIFI_IFACE
sudo service hostapd start
sudo service dnsmasq start

