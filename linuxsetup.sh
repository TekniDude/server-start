#!/bin/bash


# script config
NEWUSER="tekni"
TIMEZONE="America/New_York"
PACKAGES="git curl sudo fail2ban unattended-upgrades ufw logwatch libdate-manip-perl"


# application variables
APPVERSION="2018-06-18"
SCRIPTURL="https://github.com/TekniDude/server-start/raw/master/scripts/"


#
# print intro
#
echo "Server Prep script by Jason@TekniDude.com $APPVERSION"
echo ""


#
# check for root
#
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 1>&2
    exit 1
fi


#
# confirm
#
read -r -p "Do you want to proceed? [y/N] " response
response=${response,,}    # tolower
if [[ ! $response =~ ^(yes|y)$ ]]; then
    echo "Goodbye!"
    exit 1
fi

#
# addline(line, file) function
# Add line to file if it does not already exist.
#
function addline() {
  grep -q -F "$1" "$2" || echo "$1" >> "$2"
}


#
# checkPkg(package) function
# Check if package is installed.
#
function checkPkg() {
  return $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed")
}


#
# set local timezone
#
if [ -n "$TIMEZONE" ]; then
  echo "$TIMEZONE" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
  echo "Timezone set to $TIMEZONE"
fi


#
# set default locale
#
# enable en_US.UTF-8 locale
#sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
# generate locale files
##locale-gen "en_US.UTF-8 UTF-8"
#dpkg-reconfigure locales
# update /etc/default/locale
#update-locale LANG="en_US.UTF-8"

#
# apt update and dist-upgrade
#
apt-get update && apt-get dist-upgrade -y


#
# install favorite packages
#
if [ -n "$PACKAGES" ]; then
  apt-get install -y $PACKAGES
fi


#
# setup unattended-upgrades
#
checkPkg "unattended-upgrades"
if [ $? -eq 1 ]; then
  echo "Setting up unattended-upgrades..."
  cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
// Enable the update/upgrade script (0=disable)
APT::Periodic::Enable "1";
// Do "apt-get update" automatically every n-days (0=disable)
APT::Periodic::Update-Package-Lists "1";
// Do "apt-get upgrade --download-only" every n-days (0=disable)
APT::Periodic::Download-Upgradeable-Packages "1";
// Run the "unattended-upgrade" security upgrade script every n-days (0=disabled)
APT::Periodic::Unattended-Upgrade "1";
// Do "apt-get autoclean" every n-days (0=disable)
APT::Periodic::AutocleanInterval "7";
EOF
fi


#
# setup ufw - Uncomplicated Firewall
#
checkPkg "ufw"
if [ $? -eq 1 ]; then
  echo "Setting up ufw..."
  ufw default deny incoming
  ufw default allow outgoing
  ufw limit ssh		# allow ssh in but rate limit
  ufw allow http	# allow http in
  ufw allow https	# allow https in
  ufw --force enable	# enable and do not prompt for confirmation
fi


#
# logwatch
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
# motd script
#
wget -O - "${SCRIPTURL}motd.sh" > /etc/profile.d/motd.sh
echo "Added /etc/profile.d/motd.sh"


#
# color prompt
# the .bashrc profile will override this
#
wget -O - "${SCRIPTURL}color_prompt.sh" > /etc/profile.d/color_prompt.sh
echo "Added /etc/profile.d/color_prompt.sh"


#
# add secondary user
#
if [[ -n "$NEWUSER" ]]; then
    # create user account
    adduser --disabled-login --gecos "Login user" $NEWUSER
    # add user to sudo group
    usermod $NEWUSER -a -G sudo
    # restrict outside read to home directory
    chmod 750 "/home/$NEWUSER"

    # bash aliases
    wget -O - "${SCRIPTURL}bash_aliases.sh" > /home/$NEWUSER/.bash_aliases
    chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.bash_aliases"

    # color_prompts
    sed -i -e 's/#force_color_prompt/force_color_prompt/g' /home/$NEWUSER/.bashrc

    # .nanorc
    FILE="/home/$NEWUSER/.nanorc"
    #addline "set undo" "$FILE"
    addline "set const" "$FILE"
    chown $NEWUSER:$NEWUSER "$FILE"

    echo "New user $NEWUSER added. You must run 'passwd $NEWUSER' to set a password in order to use the account."
fi


#
# done
#
echo "Finished! If the kernel updated you should reboot the system."
