#!/bin/bash

# Creates a colorful & informative "message of the day (motd)".
# Save as /etc/profile.d/motd.sh
# Written by I. Attir.
# http://www.good-linux-tips.com

# Setting variables for ANSI colors

White="\033[01;37m"
Blue="\033[01;34m"
Green="\033[0;32m"
Nill="\033[0m"

# Local vars
Hostname=$(hostname -A | xargs -n1 | sort -u | xargs)
IP=$(ip -4 addr show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs)
OS=$(cat /etc/*version)
UPTIME=$(uptime -p| cut -d' ' -f2-)
if [ -z "$UPTIME" ]
then
  UPTIME=$(awk '{print int($1)}' /proc/uptime)" seconds"
fi

MEMORY=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)\n", $3,$2,$5}')

# Displaying colorful info: hostname, OS, kernel and username.

source /etc/os-release
#echo
echo -e "$Green================================================================================$Blue
Welcome to $White$Hostname $Blue($White$IP$Blue)
This system is running $White$PRETTY_NAME$Blue (Version: $White$OS$Blue)
Kernel version: $White$(uname -rs)$Blue
Memory usage:   $White$MEMORY$Blue
Disk usage:     $White$DISK$Blue
System uptime:  $White$UPTIME$Blue
You're currently logged in as $White$(whoami) $Blue($White$(tty)$Blue)
$Green================================================================================$Blue"
#echo

# Calling the "cowsay" program.

#cowsay "Unauthorized use of this system is strictly prohibited!"

echo -en $Nill
#echo

unset White Blue Green Nill
