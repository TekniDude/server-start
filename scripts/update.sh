# update.sh
# Download a new copy of motd from the repo.

echo "Downloading the latest version of motd..."
sudo wget -O /etc/profile.d/motd.sh https://github.com/TekniDude/server-start/raw/master/scripts/motd.sh
echo "Done!"
