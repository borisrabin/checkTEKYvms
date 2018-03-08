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
yum install net-tools -y

#echo -e "\e[1;34mThis is a blue text.\e[0m"
#echo -e "\e[1;32mThis is a green\e[0m"
#echo -e "\e[1;31mThis is a red\e[0m"
# get hostname
SRV_NAME=$(hostname)
# get IP address
NIC_NAME=$(nmcli dev status | grep conn | sed 's/\|/ /'|awk '{print $1}')
IP_ADDR=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

# Determine OS and get version 
getOS()
{
if [ -f '/etc/redhat-release' ]; then
   centosversion=$( cat /etc/redhat-release | grep -oP "[0-9]+" | head -1 )
   echo -e "\e[1;34mCentOS: $centosversion\e[0m" 
   return $centosversion   
else
   echo -e "\e[1;34mNOT CentOS\e[0m"
   return 0 
fi
}
# check firewalld running
FRWL_STATE=$(firewall-cmd --state)
FRWL_SERVICES=$(firewall-cmd --zone=public --list-services)
FRWL_PORTS=$(firewall-cmd --zone=public --list-ports)
# selinux status
#sestatus
# list cron jobs
#crontab -l

# ssh port
#cat /etc/ssh/sshd_config | grep Port
#cat /etc/ssh/sshd_config | grep 22

# dns servers
#cat /etc/resolv.conf
# ntp server
#cat /etc/ntp.conf | grep server
# memmory
#free -h

# hdd
#df -h
# non standard accounts
#cat /etc/passwd



# software installed fail2ban , naios ...








########################### DISPLAYA ON SCREEN #############################
echo -e "\e[1;34mServer name: $SRV_NAME\e[0m"
echo -e "\e[1;34mNIC: $NIC_NAME\e[0m"
echo -e "\e[1;34mIP address: $IP_ADDR\e[0m"

getOS

if [ $? -eq 7 ]
then
echo "-----Firewall-----"
echo $FRWL_STATE 
echo $FRWL_SERVICES 
echo $FRWL_PORTS
elif [ $? -eq 7 ]
then
echo "-----Firewall-----"
service iptables status 
iptables -L
else
echo #echo -e "\e[1;31m"Unknown OS and Firewall"\e[0m"
fi





