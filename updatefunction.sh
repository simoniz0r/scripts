#!/bin/bash
# Sample function that easily updates scripts based on remote text file containing version and change notes.

DDVER="1.3.3"
SCRIPTNAME="$0"

updatescript () {
cat >/tmp/updatescript.sh <<EOL
rm -f $SCRIPTNAME
wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/discorddownloader.sh"
chmod +x $SCRIPTNAME
rm -f /tmp/updatescript.sh
exec $SCRIPTNAME
exit 0
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/version.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/version.txt 2>&1 | grep DDVER= | tr -d 'DDVER="')
    if [[ $DDVER != $VERTEST ]]; then
        echo "Installed version: $DDVER -- Current version: $VERTEST"
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
        echo "Installed version: $DDVER -- Current version: $VERTEST"
        echo "discorddownloader is up to date."
        echo
        main
    fi
}

main () {
    echo $0
}

updatecheck
main