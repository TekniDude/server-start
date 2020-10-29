#!/bin/bash


#
# Script configuration
# Edit these settings
#
NEWUSER="tekni"                 # working user to add
TIMEZONE="America/New_York"     # local timezone
PACKAGES_BASIC="sudo"           # pacakges to install
#PACKAGES_EXTRA="git curl fail2ban unattended-upgrades ufw logwatch libdate-manip-perl"
PACKAGES_EXTRA="git curl ufw"                                           # suggested packages to install
APT_UPGRADE="dist-upgrade"                                              # apt mode for upgrade
APT_UP="apt update && apt list --upgradable && apt $APT_UPGRADE -y"     # full string to run for apt upgrade


#
# Application variables
#
APPVERSION="2020-10-29"
SCRIPTURL="https://github.com/TekniDude/server-start/raw/master/scripts/"


#
# bash color variables
#
C_RST="\e[0m"
C_RED="\e[31m"
C_DIM="\e[2m"
C_UND="\e[4m"


#
# Print script intro message
#
echo -e "${C_RED}Server/container/VM prep script.${C_RST} Make Life Easy ${APPVERSION}"
echo -e "${C_DIM}Created by: Jason Volk <jason@teknidude.com> github.com/teknidude${C_RST}\n"


## Script flow
# apt update & upgrade?
# install basic packages?
# install extra packages?
# motd script?
# add user?
# update timezone?
# setup packages


#
# Check for root
#
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 1>&2
    exit 1
fi

#
# Script exit message
#
echo -e "Press Ctrl+C to abort"

#
# checkPkg(package) function
# Check if package is installed.
#
function checkPkg() {
  return $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed")
}


#
# addline(line, file) function
# Add line to file if it does not already exist.
#
function addline() {
  grep -q -F "$1" "$2" || echo "$1" >> "$2"
}


#
## Run apt update?
#
echo
read -r -p "Update system? ($APT_UPGRADE) [Y/n] " response
response=${response:-Y}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    #echo "CMD: $APT_UP"
    eval $APT_UP
fi


#
## Install basic packages?
#
echo
read -r -p "Install basic packages? ($PACKAGES_BASIC) [Y/n] " response
response=${response:-Y}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    #echo "CMD: apt install -y $PACKAGES_BASIC"
    apt install -y $PACKAGES_BASIC
fi


#
# Install extra packages?
#
echo
read -r -p "Install extra packages? ($PACKAGES_EXTRA) [y/N] " response
response=${response:-N}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    #echo "CMD: apt install -y $PACKAGES_EXTRA"
    apt install -y $PACKAGES_EXTRA
fi


#
# MOTD script
#
echo
read -r -p "Install MOTD script? [Y/n] " response
response=${response:-Y}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    wget -O - "${SCRIPTURL}motd.sh" > /etc/profile.d/motd.sh
    #echo "Added /etc/profile.d/motd.sh"
fi


#
# Color prompt
# The .bashrc profile will override this #DISABLED
#
#wget -O - "${SCRIPTURL}color_prompt.sh" > /etc/profile.d/color_prompt.sh
#echo "Added /etc/profile.d/color_prompt.sh"


#
# Add 2nd user?
#
echo
read -r -p "Add primary working user? ($NEWUSER) [Y/n] " response
response=${response:-Y}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    if ! id "$NEWUSER" &>/dev/null; then
        # Create user account
        adduser --disabled-login --gecos "Login user" $NEWUSER
        echo "New user added."

        # Give user sudo access if installed
        checkPkg "sudo"
        if [ $? -eq 1 ]; then
            # add user to sudo group
            usermod $NEWUSER -a -G sudo
            echo "User added to sudo group."
        fi

        # Restrict outside read to home directory
        chmod 750 "/home/$NEWUSER"
        echo "User home chmod to 750."

        # Download favorite bash aliases
        wget -O - "${SCRIPTURL}bash_aliases.sh" > /home/$NEWUSER/.bash_aliases && chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.bash_aliases" && echo "User aliases added."

        # Force color_prompt
        sed -i -e 's/#force_color_prompt/force_color_prompt/g' /home/$NEWUSER/.bashrc && echo "User color prompts on."

        # Update history size
        sed -i -e "s/HISTSIZE=.*/HISTSIZE=10000/" .bashrc
        sed -i -e "s/HISTFILESIZE=.*/HISTFILESIZE=20000/" .bashrc
        echo "History size expanded."

        #echo "New user $NEWUSER added. You must run 'passwd $NEWUSER' to set a password in order to use the account."
        echo "Set the password for the new user:"
        passwd $NEWUSER
    else
        echo "New user skipped: User already exists on system."
    fi
fi


#
# Set local timezone?
#
echo
read -r -p "Update system timezone? ($TIMEZONE) [Y/n] " response
response=${response:-Y}     # default
response=${response,,}      # tolower
if [[ $response =~ ^(yes|y)$ ]]; then
    if [ -n "$TIMEZONE" ]; then
        #echo "$TIMEZONE" > /etc/timezone
        #dpkg-reconfigure -f noninteractive tzdata
        timedatectl set-timezone $TIMEZONE
        echo "Timezone set to $TIMEZONE"
    else
        echo "Timezone skipped!"
    fi
fi


#
# Run commands now
# TBD
#



#
# Set default locale
# DISABLED
#
# enable en_US.UTF-8 locale
#sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
# generate locale files
##locale-gen "en_US.UTF-8 UTF-8"
#dpkg-reconfigure locales
# update /etc/default/locale
#update-locale LANG="en_US.UTF-8"


#
# Setup ufw - Uncomplicated Firewall
# Default settings: allow all outgoing, incoming only: limit ssh, allow http & https,
#
checkPkg "ufw"
if [ $? -eq 1 ]; then
  echo "Setting up ufw..."
  ufw default deny incoming
  ufw default allow outgoing
  ufw limit ssh     # allow ssh in but rate limit
  ufw allow http    # allow http in
  ufw allow https   # allow https in
  ufw --force enable    # enable and do not prompt for confirmation
fi


#
# Setup logwatch
# NEEDS UPDATE
#
#checkPkg "logwatch"
#if [ $? -eq 1 ]; then
#  echo "Setting up logwatch..."
#  addline "Range = between -7 days and -1 days" "/etc/logwatch/conf/logwatch.conf"
#  addline "Output = html" "/etc/logwatch/conf/logwatch.conf"
#  #addline "" "/etc/logwatch/conf/logwatch.conf"
#  mv /etc/cron.daily/00logwatch /etc/cron.weekly/
#fi

#
# Setup unattended-upgrades
# NEEDS UPDATE
#
# checkPkg "unattended-upgrades"
# if [ $? -eq 1 ]; then
#   echo "Setting up unattended-upgrades..."
#   cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
# // Enable the update/upgrade script (0=disable)
# APT::Periodic::Enable "1";
# // Do "apt-get update" automatically every n-days (0=disable)
# APT::Periodic::Update-Package-Lists "1";
# // Do "apt-get upgrade --download-only" every n-days (0=disable)
# APT::Periodic::Download-Upgradeable-Packages "1";
# // Run the "unattended-upgrade" security upgrade script every n-days (0=disabled)
# APT::Periodic::Unattended-Upgrade "1";
# // Do "apt-get autoclean" every n-days (0=disable)
# APT::Periodic::AutocleanInterval "7";
# EOF
# fi


#
# Done
#
echo "Finished! If the kernel was updated you should reboot the system."