# server-start

Prep script to load default packages, setup bash, and secure. Packages include: git curl sudo fail2ban unattended-upgrades ufw

## Install

Download the script and run linuxsetup.sh as root.

```bash
# wget --no-check-certificate https://github.com/TekniDude/server-start/raw/master/linuxsetup.sh
# bash linuxsetup.sh
```


## motd only

If you only want to update the motd script then run this:

```bash
$ sudo wget -O /etc/profile.d/motd.sh https://github.com/TekniDude/server-start/raw/master/scripts/motd.sh
```
