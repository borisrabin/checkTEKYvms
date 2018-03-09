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
#  print non standard accounts
#  make sure fail2ban installed and runs on port 49100 for ssh
#  nagios service installed and started
# ossec installed and started

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    true
  else
    false
  fi
}
if isinstalled net-tools
then
echo -e "\e[1;32mnet-tools installed\e[0m"
else 
yum install net-tools -y
fi


#echo -e "\e[1;34mThis is a blue text.\e[0m"
#echo -e "\e[1;32mThis is a green\e[0m"
#echo -e "\e[1;31mThis is a red\e[0m"
# get hostname
SRV_NAME=$(hostname)
# get IP address
NIC_NAME=$(nmcli dev status | grep conn | sed 's/\|/ /'|awk '{print $1}')
IP_ADDR=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')



SE_STATUS=$(sestatus | sed 's/\|/ /'|awk '{print $3}')


############
# FUNCTION #
############

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
# Get ssh port

getSSHPORT(){
portnum=$(cat /etc/ssh/sshd_config | grep Port | sed 's/\|/ /'|awk '{print $2}' | sed -n '1p')
return $portnum
}

getNTP(){
file="/etc/ntp.conf"
if [ -f "$file" ]
then
	cat /etc/ntp.conf | grep -v '^#' | grep server
else
	echo -e "\e[1;31m NTP not installed\e[0m"

fi

}

########################### DISPLAYA ON SCREEN #############################
echo -e "\e[1;34mServer name: $SRV_NAME\e[0m"
echo -e "\e[1;34mNIC: $NIC_NAME\e[0m"
echo -e "\e[1;34mIP address: $IP_ADDR\e[0m"
# centos version
echo "                   "
getOS
#   firewall info

if [ $? -eq 7 ]
then
echo -e "\e[1;34mCentOS 7 Firewall\e[0m"

firewall-cmd --state
firewall-cmd --zone=public --list-services
firewall-cmd --zone=public --list-ports

elif [ $? -eq 6 ]
then
echo -e "\e[1;34mCentOS6 Firewall\e[0m"

service iptables status 
iptables -L
else
echo -e "\e[1;31m"Unknown OS and Firewall"\e[0m"
fi
# selinux status
echo "                          "
echo -e "\e[1;34mSELINUX STATUS\e[0m"

if [ "$SE_STATUS" == "disabled" ]
then
echo -e "\e[1;31mSELINUX disabled\e[0m"
else 
echo -e "\e[1;32mSELINUX ACTIVE\e[0m"
fi
#list cron jobs
echo "                      "
echo -e "\e[1;34mCron Jobs \e[0m"
echo -e "\e[1;34m------------\e[0m"

crontab -l
# show port
echo "                     "
getSSHPORT
echo -e "\e[1;34mSSH Port: $?\e[0m"
# show dns servers
echo "           "
echo -e "\e[1;34mDNS Servers\e[0m" 
cat /etc/resolv.conf | grep -v '^#' | grep server

# ntp servers
echo "                      "
echo -e "\e[1;34mNTP SERVER \e[0m"
getNTP
echo "                      "
# find non standard accounts
u_list=$(cut -d: -f1 /etc/passwd)
u_std_list="
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
operator
games
ftp
nobody
systemd-network
dbus
polkitd
postfix
chrony
sshd
ntp
"
echo -e "\e[1;34mNon standard accounts\e[0m"
echo -e "\e[1;34m-------------------\e[0m"

diff <(echo "$u_list") <(echo "$u_std_list") | grep -E '<' | cut -c 2-

