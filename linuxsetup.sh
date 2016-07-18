#!/bin/bash

MYVERSION="2016-07-17"
NEWUSER="tekni"


#
# print intro
#
echo "Server Prep script by Jason@TekniDude.com $MYVERSION"
echo ""


#
# check for root
#
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi


#
# confirm
#
read -r -p "Do you want to proceed? [y/n] " response
response=${response,,}    # tolower
if [[ ! $response =~ ^(yes|y)$ ]]; then
    exit 1
fi
echo "continue!"


#
# set local timezone
#
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
echo "Timezone set"


#
# apt update and dist-upgrade
#
apt-get update && apt-get dist-upgrade -y


#
# install favorite packages
#
apt-get install -y git curl sudo fail2ban unattended-upgrades ufw


#
# TODO install and setup unattended-upgrades
#


#
# TODO install and setup ufw
#
echo "Setting up ufw..."
ufw default deny incoming
ufw default allow outgoing
ufw limit ssh
ufw allow http
ufw allow https
ufw --force enable # enable and do not prompt for confirmation

#
# motd script
#
wget -O - "http://wiki.jasonvolk.net/_export/code/vps/new_server?codeblock=2" > /etc/profile.d/motd.sh
echo "Added motd.sh"


#
# color prompt
#
wget -O - "http://wiki.jasonvolk.net/_export/code/vps/new_server?codeblock=3" > /etc/profile.d/color_prompt.sh


#
# add secondary user
#
if [[ -n "$NEWUSER" ]]; then
    adduser --disabled-login --gecos "Login user" $NEWUSER
    # add user to sudo group
    usermod $NEWUSER -a -G sudo

    # bash aliases
    wget -O - "http://wiki.jasonvolk.net/_export/code/vps/new_server?codeblock=4" > /home/$NEWUSER/.bash_aliases
    chown $NEWUSER:$NEWUSER /home/$NEWUSER/.bash_aliases

    # color_prompts
    sed -i -e 's/#force_color_prompt/force_color_prompt/g' /home/$NEWUSER/.bashrc

    echo "New user $NEWUSER added. You must run 'passwd $NEWUSER' to set a password in order to use the account."
fi


#
# done
#
unset NEWUSER MYVERSION
echo "Finished!"