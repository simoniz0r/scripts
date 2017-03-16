#!/bin/bash
# Add this to discorddownloader with a method to update
# Figure out how to use 'grep' or something similar to get version directly from script instead of needing separate file!

DDVER="1.3.3"

updatecheck () {
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/discorddownloader.sh 2>&1 | grep DDVER= | tr -d 'DDVER="')
    if [[ $DDVER != $VERTEST ]]; then
        echo "outdated!"
        wget -o urltoupdatescript ./updatescript
        exec ./updatescript # contains find -name to find old version, rm to remove it, wget -o to download new version, chmod +x new version, deletes self after update, and runs new version
        exit 0
    else
        echo "up to date!"
    fi
}

main () {
    echo "discorddownloader stuff"
}

updatecheck
main