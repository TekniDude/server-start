# Creates a colorful & informative "message of the day (motd)"
# Save as /etc/profile.d/motd.sh
# Original script by I. Attir http://www.good-linux-tips.com
# Update by Jason Volk <jason@teknidude.com>

(  # run in a subshell() to keep vars out of main BASH scope

SCRIPT_VERSION="2016-11-18"
SCRIPT_MSG="\t${BASH_ARGV:=$0} v. $SCRIPT_VERSION"

# Setting variables for ANSI colors
White="\033[01;37m"
Blue="\033[01;34m"
Green="\033[0;32m"
Nill="\033[0m"
Gray="\e[38;5;233m"

# Locale
#export LANG=en_US.UTF-8
#echo $(printf "%'d\n" 12345678)


# Get hostname
HOSTNAME=$(hostname -A | xargs -n1 | sort -u | xargs)
if [ -z "$HOSTNAME" ]; then
  HOSTNAME=$(hostname -f)
fi

# Get all IPs
IP=$(ip -4 addr show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs)

# Get system & kernel version
OS=$(cat /etc/*version)
KERNEL=$(uname -rs)

# Get uptime
UPTIME=$(uptime -p| cut -d' ' -f2-)
if [ -z "$UPTIME" ]
then
  # if uptime is blank show in seconds. (uptime -p is blank when boot time is <60s)
  UPTIME=$(awk '{print int($1)}' /proc/uptime)" seconds"
fi

# Hardware
#CPU_NAME=$(lscpu | grep -oP 'Model name:\s*\K.+')
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo|cut -d' ' -f 3-)
CPU_NUM=$(grep -c ^processor /proc/cpuinfo)

# Usage
MEMORY=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)\n", $3,$2,$5}')

# Displaying colorful info: hostname, OS, kernel and username.
source /etc/os-release
echo -e "$Green================================================================================$Blue$Gray$SCRIPT_MSG$Blue
Welcome to $White$HOSTNAME $Blue($White$IP$Blue)
This system is running $White$PRETTY_NAME$Blue (Version: $White$OS$Blue)
Kernel version: $White$KERNEL$Blue
Hardware:       ${White}${CPU_NUM}${Blue}x ${White}${CPU_MODEL}${Blue}
Memory usage:   $White$MEMORY$Blue
Disk usage:     $White$DISK$Blue
System uptime:  $White$UPTIME$Blue
You're currently logged in as $White$(whoami) $Blue($White$(tty)$Blue)
$Green================================================================================$Blue"

TEST="var should be unset"

# Calling the "cowsay" program.
#cowsay "Unauthorized use of this system is strictly prohibited!"

# Reset bash color
echo -en $Nill

# Done
#exit 0
)
