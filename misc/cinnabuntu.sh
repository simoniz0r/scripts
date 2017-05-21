#!/bin/bash
# Installs cinnamon-desktop-environment on Ubuntu 16.04 or later

clear
echo "Updating package list..."
sudo apt update || { echo "Update failed; make sure you are connected to the internet and try again." ; exit 1 ; }
clear
echo "Upgrading already installed packages..."
sudo apt upgrade -y || { echo "Upgrade failed; make sure you are connected to the internet and try again." ; exit 1 ; }
clear
read -p -n 1 -r "Installing Cinnamon Desktop Environment; this will take several minutes.  Press any key to continue."
sudo apt install cinnamon-desktop-environment -y || { echo "Cinnamon Desktop Environment install failed; make sure you are connected to the internet and try again.." ; exit 1 ; }
clear
read -p -n 1 -r "Cinnamon Desktop Environment Installed!  Press any key to restart. "
shutdown -r now