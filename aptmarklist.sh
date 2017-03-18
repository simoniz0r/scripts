#!/bin/bash
# A script that outputs the results of apt-mark in alphabetical order.
# Provides arguments to write the output to a file and list number of installed packages.
# Can also install packages from the outputted file.
# Base command found here: http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages

AMVER="1.0.0"
X="v1.0.0 - Added self updating functions."
# ^^ Remember to update these and aptmarklistversion.txt every release!
SCRIPTNAME="$0"

aptmarklist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

help () {
    echo "Outputs the result of apt-mark in alphabetical order by default."
    echo "Arguments:"
    echo "-h : Shows this help dialog."
    echo "-w : Writes the output to ~/.packagelist.txt"
    echo "-c : Write output to custom file. Ex: 'aptmarklist.sh -c ~/mypackages.txt'"
    echo "-n : Outputs the number of user installed packages."
    echo "-i : Installs packages from package list file. Use full path name.  Ex: aptmarklist.sh -i /home/simonizor/packagelist.txt"
}

main () {
    ARG=$1
    if [[ "$ARG" == -* ]]; then
        while getopts ":hwcni" opt; do
            case "$opt" in
            h|\?|help)
                help
                exit 0
                ;;
            w)
                aptmarklist | tee ~/packagelist.txt
                ;;
            c)
                OUTPUT=$2
                aptmarklist | tee $OUTPUT
                ;;
            n)
                aptmarklist | wc -l
                ;;
            i)
                PACKAGELIST=$2
                xargs -a <(awk '/^\s*[^#]/' "$PACKAGELIST") -r -- sudo apt install
            esac
        done
    else
        aptmarklist
    fi
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
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklist.sh"
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
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklistversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/aptmarklistversion.txt 2>&1 | grep AMVER= | tr -d 'AMVER="')
    if [[ $AMVER != $VERTEST ]]; then
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
            main
        fi
    else
        echo "Installed version: $AMVER -- Current version: $VERTEST"
        echo "aptmarklist.sh is up to date."
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