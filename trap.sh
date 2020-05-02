#!/bin/sh
WIFI_IFACE=wlp2s0
ETH_IFACE=enp3s0
[ ! -f /etc/dnsmasq.conf ] && sudo apt install dnsmasq -y
[ ! -f /etc/hostapd/hostapd.conf ] && sudo apt install hostapd -y
sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo sed -i "s/wlan0/$WIFI_IFACE/g" /etc/dnsmasq.conf
sudo sed -i "s/eth0/$ETH_IFACE/g" /etc/dnsmasq.conf
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo sed -i "s/wlan0/$WIFI_IFACE/g" /etc/hostapd/hostapd.conf
sudo sed -i "s/eth0/$ETH_IFACE/g" /etc/hostapd/hostapd.conf
sudo iptables -tnat -A POSTROUTING -o $ETH_IFACE -j MASQUERADE
sudo echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo echo nameserver 8.8.4.4 >> /etc/resolv.conf
sudo iw dev $WIFI_IFACE disconnect
sudo ip addr replace 192.168.2.1/24 dev $WIFI_IFACE
sudo service hostapd start
sudo service dnsmasq start

