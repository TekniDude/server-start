#!/bin/bash

# Creates a colorful & informative "message of the day (motd)"
# Save as /etc/profile.d/motd.sh
# Original script by I. Attir http://www.good-linux-tips.com
SCRIPT_VERSION="2016-09-30"


# Setting variables for ANSI colors
White="\033[01;37m"
Blue="\033[01;34m"
Green="\033[0;32m"
Nill="\033[0m"
Gray="\e[38;5;232m"

# Locale
#export LANG=en_US.UTF-8
#echo $(printf "%'d\n" 12345678)


# Local vars
HOSTNAME=$(hostname -A | xargs -n1 | sort -u | xargs)
IP=$(ip -4 addr show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs)
OS=$(cat /etc/*version)
KERNEL=$(uname -rs)
UPTIME=$(uptime -p| cut -d' ' -f2-)
if [ -z "$UPTIME" ]
then
  # if uptime is blank show in seconds. (uptime -p is blank when boot time is <60s)
  UPTIME=$(awk '{print int($1)}' /proc/uptime)" seconds"
fi

# Hardware
CPU=$(lscpu | grep -oP 'Model name:\s*\K.+')
CPUs=$(grep -c ^processor /proc/cpuinfo)

# Usage
MEMORY=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)\n", $3,$2,$5}')

# Displaying colorful info: hostname, OS, kernel and username.
source /etc/os-release
echo -e "$Green================================================================================$Blue	$Gray$0 v. $SCRIPT_VERSION$Blue
Welcome to $White$HOSTNAME $Blue($White$IP$Blue)
This system is running $White$PRETTY_NAME$Blue (Version: $White$OS$Blue)
Kernel version: $White$KERNEL$Blue
Hardware:       ${White}${CPUs}${Blue}x ${White}${CPU}${Blue}
Memory usage:   $White$MEMORY$Blue
Disk usage:     $White$DISK$Blue
System uptime:  $White$UPTIME$Blue
You're currently logged in as $White$(whoami) $Blue($White$(tty)$Blue)
$Green================================================================================$Blue"


# Calling the "cowsay" program.
#cowsay "Unauthorized use of this system is strictly prohibited!"

# Reset bash color
echo -en $Nill

# Done
exit 0
