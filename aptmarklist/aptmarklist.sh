#!/bin/bash
# A script that outputs the results of apt-mark in alphabetical order.
# Provides arguments to write the output to a file and list number of installed packages.
# Can also install packages from the outputted file.
# Base command found here: http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages

AMVER="1.1.2"
X="v1.1.2 - Made it clear that 'curl' is needed for updates."
# ^^ Remember to update these and aptmarklistversion.txt every release!
SCRIPTNAME="$0"

aptmarklist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

help () {
    echo "Outputs the number of user installed packages witout any arguments."
    echo "Arguments:"
    echo "-h : Shows this help dialog."
    echo "-l : Outputs list of packages installed and number without writing to file."
    echo "-w : Writes the output to ~/.packagelist.txt or different file  if specified. Ex: 'aptm -w' or 'aptm -w ./mypackages.txt'"
    echo "-i : Installs packages from package list file. Ex: sudo ./aptmarklist.sh -i /home/simonizor/packagelist.txt"
    echo "-u : Check for updated version of aptmarklist.sh."
}

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    rm -f $SCRIPTNAME
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklist/aptmarklist.sh"
    chmod +x $SCRIPTNAME
    if [ -f $SCRIPTNAME ]; then
        echo "Update finished!"
        rm -f /tmp/updatescript.sh
        exit 0
    else
        read -p "Update Failed! Try again? Y/N " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            runupdate
        else
            echo "aptmarklist.sh was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklist/aptmarklistversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklist/aptmarklistversion.txt 2>&1 | grep AMVER= | tr -d 'AMVER="')
    if [[ $AMVER < $VERTEST ]]; then
        echo "Installed version: $AMVER -- Current version: $VERTEST"
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
            echo "aptmarklist.sh was not updated."
        fi
    else
        echo "Installed version: $AMVER -- Current version: $VERTEST"
        echo $UPNOTES
        echo "aptmarklist.sh is up to date."
    fi
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type $PROGRAM >/dev/null 2>&1 || { return=0; }
  # return value
}

ARG=$1
if [[ "$ARG" == -* ]]; then
    while getopts ":hwliu" opt; do
        case "$opt" in
        h|\?|help)
            help
            exit 0
            ;;
        w)
            NUM=$(aptmarklist | wc -l)
            if [ -z "$2" ]; then
                OUTPUT=~/packagelist.txt
            else
                OUTPUT=$2
            fi
            aptmarklist | tee $OUTPUT &>/dev/null
            echo "$ Total number of user installed packages: $NUM"
            if [ -f $OUTPUT ]; then
                echo "$ $OUTPUT"
                cat $OUTPUT
            else
                echo "$ Failed to write file $OUTPUT !"
            fi
            ;;
        l)
            NUM=$(aptmarklist | wc -l)
            echo "$ Packages"
            aptmarklist
            echo "$ Total number of user installed packages: $NUM"
            ;;
        i)
            PACKAGELIST=$2
            xargs -a <(awk '/^\s*[^#]/' "$PACKAGELIST") -r -- apt install
            ;;
        u)
            PROGRAM="curl"
            programisinstalled
            if [ "$return" = "1" ]; then
                updatecheck
            else
                echo "$PROGRAM is not installed; cannot check for updates!"
                exit 1
            fi
        esac
    done
else
    NUM=$(aptmarklist | wc -l)
    echo "$ Total number of user installed packages: $NUM"
fi