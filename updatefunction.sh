#!/bin/bash
# Add this to discorddownloader with a method to update
# Figure out how to use 'grep' or something similar to get version directly from script instead of needing separate file!

DDVER="1.3.3"
SCRIPTNAME="$0"

updatecheck () {
    echo "Checking for new version..."
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/discorddownloader.sh 2>&1 | grep DDVER= | tr -d 'DDVER="')
    if [[ $DDVER != $VERTEST ]]; then
        echo "There is a new version of discorddownloader available; updating now."
        echo "Creating update script..."
        echo "rm -f $SCRIPTNAME /n wget -o https://raw.githubusercontent.com/simoniz0r/discorddownloader/master/discorddownloader.sh $SCRIPTNAME /n chmod +x $SCRIPTNAME /n rm -f ~/Downloads/updatescript.sh /n exec $SCRIPTNAME /n exit 0" > ~/Downloads/updatescript.sh
        chmod +x ~/Downloads/updatescript.sh
        echo "Running update script..."
        exec ~/Downloads/updatescript.sh
        exit 0
    else
        echo "discorddownloader is up to date."
    fi
}

main () {
    echo $0
}

updatecheck
main