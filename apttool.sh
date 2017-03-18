#!/bin/bash
# A simple script that can run apt options to save keystrokes.

APTTVER="1.0.1"
X="v1.0.1 - Cleaned up package list output."
# ^^ Remember to update these and apttversion.txt every release!
SCRIPTNAME="$0"

main () {
    echo "What would you like to do?"
    echo "1 - Run apt update."
    echo "2 - Run apt upgrade."
    echo "3 - Run apt show."
    echo "4 - Run apt search."
    echo "5 - Run apt install."
    echo "6 - List user installed packages."
    echo "7 - Run apt remove."
    echo "8 - Run apt autoremove."
    echo "9 - Exit."
    read -p "Choice? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]; then
        sudo apt update
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[2]$ ]]; then
        sudo apt upgrade
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[3]$ ]]; then
        read -p "What package would you like to show info for? " SHOW
        echo
        apt show $SHOW
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[4]$ ]]; then
        read -p "What package would you like to search for? " SEARCH
        echo
        apt search $SEARCH
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[5]$ ]]; then
        read -p "What package would you like to install? " INSTALL
        echo
        sudo apt install $INSTALL
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[6]$ ]]; then
        NUM=$(packagelist | wc -l)
        echo "-- Packages --"
        packagelist
        echo "-- Total number of user installed packages: $NUM --"
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[7]$ ]]; then
        read -p "What package would you like to remove? " REMOVE
        echo
        sudo apt remove $REMOVE
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[8]$ ]]; then
        echo
        echo
        echo "Use with caution! Be sure to read through the packages"
        echo "listed to make sure you do not need them!"
        echo
        echo
        sudo apt autoremove
        echo
        echo "--Finshed--"
        echo
        main
    else
        exit 1
    fi
}

packagelist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type $PROGRAM >/dev/null 2>&1 || { return=0; }
  # return value
}

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    rm -f $SCRIPTNAME
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttool.sh"
    chmod +x $SCRIPTNAME
    if [ -f $SCRIPTNAME ]; then
        echo "Update finished!"
        rm -f /tmp/updatescript.sh
        exec $SCRIPTNAME
        exit 0
    else
        read -p "Update Failed! Try again? Y/N " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            runupdate
        else
            echo "apttool.sh was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttversion.txt 2>&1 | grep APTTVER= | tr -d 'APTTVER="')
    if [[ $APTTVER != $VERTEST ]]; then
        echo "Installed version: $APTTVER -- Current version: $VERTEST"
        echo "A new version is available!"
        echo $UPNOTES
        read -p "Would you like to update? Y/N " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo
            echo "Creating update script..."
            updatescript
            chmod +x /tmp/updatescript.sh
            echo "Running update script..."
            exec /tmp/updatescript.sh
            exit 0
        else
            echo
            main
        fi
    else
        echo "Installed version: $APTTVER -- Current version: $VERTEST"
        echo $UPNOTES
        echo "apttool.sh is up to date."
        echo
        main
    fi
}



PROGRAM="curl"
programisinstalled
if [ "$return" = "1" ]; then
    updatecheck
else
    read -p "curl is not installed; run script without checking for new version? Y/N " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        main
    else
        echo
        echo "Exiting."
        exit 0
    fi
fi