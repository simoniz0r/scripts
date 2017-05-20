#!/bin/bash
# Installs cinnamon-desktop-environment on Ubuntu 16.04 or later

echo "Updating package list..."
sudo apt update || { echo "Update failed; make sure you are connected to the internet and try again." ; exit 1 ; }
echo "Upgrading already installed packages..."
sudo apt upgrade -y || { echo "Upgrade failed; make sure you are connected to the internet and try again." ; exit 1 ; }
echo "Installing Cinnamon Desktop Environment..."
sudo apt install cinnamon-desktop-environment -y || { echo "Cinnamon Desktop Environment install failed; make sure you are connected to the internet and try again.." ; exit 1 ; }
read -p "Cinnamon Desktop Environment Installed!  Press any key to restart. "
shutdown -r now