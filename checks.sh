#!/bin/bash
# Feb 21 - 2018
# script to check services on vm and h-servers up to spec with security
#
#
##########   list of checks ###########
#  hostname
#  IP info
#  print firewall open ports
#  sestatus
#  cronjobs
#  ssh port
#  dns servers
#  ntp servers
#  free memmory
#  free hdd
#  print non standard accounts
#  swap information
#  file system healh information
#  make sure fail2ban installed and runs on port 49100 for ssh
#  nagios service installed and started
# ossec installed and started
echo -e "\e[1;34mThis is a blue text.\e[0m"
echo -e "\e[1;32mThis is a green\e[0m"
echo -e "\e[1;31mThis is a red\e[0m"
# get hostname
SRV_NAME=$(hostname)
# get IP address
NIC_NAME=$(nmcli dev status | grep conn | sed 's/\|/ /'|awk '{print $1}')
IP_ADDR=$(ifconfig $NIC_NAME | egrep -o "inet addr:[^ ]*" | grep -o "[0-9.]*")

echo $SRV_NAME
echo $IP_ADDR
# Determine OS and get version

if [ -f '/etc/redhat-release' ]; then
   centosversion=$( cat /etc/redhat-release | grep -oP "[0-9]+" | head -1 )
else
   echo "NOT CENTOS "
fi

# check firewalld running
firewall-cmd --state
firewall-cmd --zone=public --list-services
firewall-cmd --zone=public --list-ports

# selinux status
sestatus
# list cron jobs
crontab -l

# ssh port
cat /etc/ssh/sshd_config | grep Port
cat /etc/ssh/sshd_config | grep 22

# dns servers
cat /etc/resolv.conf
# ntp server
cat /etc/ntp.conf | grep server
# memmory
free -h

# hdd
df -h
# non standard accounts
cat /etc/passwd

# file system healh 

# software installed fail2ban , naios ...
