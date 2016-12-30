# server-start

Prep script to load default packages, setup bash, and secure. Packages include: git curl sudo fail2ban unattended-upgrades ufw

## Install

Download the script and run linuxsetup.sh as root.

```bash
# wget --no-check-certificate https://github.com/TekniDude/server-start/raw/master/linuxsetup.sh
# bash linuxsetup.sh
```


## motd only

![MOTD screenshot](https://cloud.githubusercontent.com/assets/16631012/21559324/6cf14984-ce18-11e6-96f7-f91d510a9f02.png)

If you only want to update the motd script then run this:

```bash
$ sudo wget -O /etc/profile.d/motd.sh https://github.com/TekniDude/server-start/raw/master/scripts/motd.sh
```
