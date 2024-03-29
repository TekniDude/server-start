# Creates a colorful & informative "message of the day (motd)"
# Save as /etc/profile.d/motd.sh
# Original script by I. Attir http://www.good-linux-tips.com
# Update by Jason Volk <jason@teknidude.com>


function motd() (  # Run in a subshell() for easy calling. Also keep vars out of main BASH scope

# Strict errors
set -e

# Version
SCRIPT_VERSION="2021-08-27"

# Print script version info if flag is passed
if [[ "$1" == "-v" || "$1" == "--version" ]]; then
  echo "${BASH_SOURCE[0]} version $SCRIPT_VERSION"
  echo "Created by Jason Volk <jason@teknidude.com> https://github.com/TekniDude/server-start"
  return 0
fi

# Setting variables for ANSI colors
White="\033[01;37m"
Blue="\033[01;34m"
Green="\033[0;32m"
Nill="\033[0m"
Gray="\e[38;5;233m"

# Horizontal rule across terminal
COLS=$(tput cols)
#COLUMNS=${COLUMNS:-80}
HR=$(printf '=%.0s' $(seq $COLS))

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
if [ -z "$UPTIME" ]; then
  # if uptime is blank show in seconds. (uptime -p is blank when boot time is <60s)
  UPTIME=$(awk '{print int($1)}' /proc/uptime)" seconds"
fi
UPSECS=$(cut -f1 -d'.' /proc/uptime)
UPSECS=$((UPSECS/60/60/24))
if [ "$UPSECS" -gt "7" ]; then
  # Display day count only if over a week
  UPTIME="$UPTIME ${Blue}(${White}$UPSECS days${Blue})${White}"
fi

# Get system avg load
LOAD=$(cut -f1,2,3 -d' ' /proc/loadavg)

# Hardware
#CPU_NAME=$(lscpu | grep -oP 'Model name:\s*\K.+')
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo|cut -d' ' -f 3- | xargs)
if [ -z "$CPU_MODEL" ]; then
  CPU_MODEL=$(dpkg --print-architecture)
fi
CPU_NUM=$(grep -c ^processor /proc/cpuinfo)
CPU_SOCKETS=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

# Usage
MEMORY=$(free -m | grep Mem | awk '{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2}')
if [ $(grep SwapTotal /proc/meminfo | cut -d':' -f2|xargs|cut -d' ' -f1) -gt "0" ]; then
  SWAP=$(free -m | grep Swap | awk '{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2}')
else
  SWAP="None"
fi
DISK=$(df -h / | awk '$NF=="/"{printf "%s/%s (%s)\n", $3,$2,$5}')

# Current user
USER=$(whoami)
TTY=$(tty)

# Pull in current OS variables from release file
source /etc/os-release

# Print out the motd message
echo -e "${Green}${HR}${Blue}
Welcome to ${White}${HOSTNAME} ${Blue}(${White}${IP}${Blue})
This system is running ${White}$PRETTY_NAME${Blue} (Version: ${White}$OS${Blue})
Kernel version: ${White}${KERNEL}${Blue}
Hardware:       ${White}${CPU_NUM}${Blue}x ${White}${CPU_MODEL}${Blue} (${White}${CPU_SOCKETS} sockets${Blue})
Memory/swap:    ${White}${MEMORY}${Blue} / ${White}$SWAP${Blue}
Disk usage:     ${White}${DISK}${Blue}
System uptime:  ${White}${UPTIME}${Blue}
Average load:   ${White}${LOAD}${Blue}
You're currently logged in as ${White}${USER} ${Blue}(${White}${TTY}${Blue})
${Green}${HR}${Blue}"

# Reset bash color
echo -en $Nill

# Done
return 0
)


# call motd function if running interactive mode
if [ -n "$BASH_VERSION" -a -n "$PS1" ]; then
  motd
fi
