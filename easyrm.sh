#!/bin/bash
# A bash script that attempts to make 'rm' easier to use by moving files to '~/.easyrmtmp' by default.
# Created by simonizor 3/11/2017

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

ERMVER="1.0.1"
X="v1.0.1 - Changed update to argument -n."
SCRIPTNAME="$0"

help () {
    echo "Tool that uses 'mv' and 'rm' to move files to '~/.easyrmtmp' instead of deleting them by default."
    echo "Usage: 'easyrm.sh /path/to/file' or 'easyrm.sh /path/to/directory/'"
    echo "Note: Directories must have the trailing '/' or you will receive an error."
    echo "Arguments:"
    echo "-h : Shows this help output"
    echo "-l : Shows list of files in '~/.easyrmtmp'"
    echo "-c : Removes all files and directories from '~/.easyrmtmp'"
    echo "-p : executes the default 'rm' command and will permanently remove files and directories."
    echo "-f : executes the 'rm' command with '-f' to forcefully and permanently remove files and directories."
    echo "-u : Removes '~/.easyrmtmp' directory and config file."
    echo "-n : Check for new version of easyrm.sh."
}

easyrm () {
    echo "$ARG will be moved to '~/.easyrmtmp'..."
    read -p "Continue? Y/N" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv $ARG ~/.easyrmtmp/
        echo "$ARG has been moved to '~/.easyrmtmp'!"
    else
        echo "$ARG was not moved!"
    fi
}

main () {
    if [ -f ~/.config/easyrm/easyrm.conf ]; then
        ARG=$1
        if [[ "$ARG" == /* ]]; then
            easyrm
        elif [[ "$ARG" == ./* ]]; then
            easyrm
        elif [[ "$ARG" == ~/* ]]; then
            easyrm
        elif [[ "$ARG" == -* ]]; then
            while getopts ":hpcfuln" opt; do
                case "$opt" in
                h|\?|help)
                    help
                    exit 0
                    ;;
                l)
                    dir ~/.easyrmtmp
                    ;;
                p)
                    echo "$2 will be permanently deleted!"
                    read -p "Continue? Y/N" -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        if [ "${2: -1}" = "/" ]; then
                            rm -r $2
                            echo "$2 was deleted permanently!"
                        else
                            rm $2
                            echo "$2 was deleted permanently!"
                        fi
                    else
                        echo "$2 was not deleted!"
                    fi
                    ;;
                c)
                    NUMBER=$(ls -l ~/.easyrmtmp | wc -l)
                    REALNUM=$(($NUMBER-1))
                    echo "The following files and/or directories in '~/.easyrmtmp' will be permanently deleted:"
                    dir ~/.easyrmtmp
                    read -p "Continue? Y/N" -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm -r ~/.easyrmtmp/*
                        echo "$REALNUM files and/or directories have been permanently deleted!"
                    else
                        echo "Files and directories in '~/.easyrmtmp' were not deleted!"
                    fi
                    ;;
                u)
                    echo "All files in '~/.easyrmtmp' will be permanently deleted and config file will be removed!"
                    read -p "Continue? Y/N" -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm -r ~/.config/easyrm/
                        rm -r ~/.easyrmtmp/
                        echo "Finished!"
                    else
                        echo "'~/.easyrmtmp' was not deleted and config file remains!"
                    fi
                    ;;
                f)
                    echo "$2 will be permanently deleted by force!"
                    read -p "Continue? Y/N" -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        if [ "${2: -1}" = "/" ]; then
                            rm -rf $2
                            echo "$2 was deleted permanently!"
                        else
                            rm -f $2
                            echo "$2 was deleted permanently!"
                        fi
                    else
                        echo "$2 was not deleted!"
                    fi
                n)
                    PROGRAM="curl"
                    programisinstalled
                    if [ "$return" = "1" ]; then
                        updatecheck
                    else
                        echo "curl is not installed; could not check for updates."
                    fi
                esac
            done
        else
            ARG="${ARG::-z}./$1"
            easyrm
        fi

        shift $((OPTIND-1))

        [ "$1" = "--" ] && shift
    else
        mkdir ~/.config/easyrm/
        echo "'~/.easyrmtmp' has been created." > ~/.config/easyrm/easyrm.conf
        echo "Directory '~/.easyrmtmp' does not exist..."
        echo "Creating '~/.easyrmtmp' directory for temporary storage of removed files/directories..."
        mkdir ~/.easyrmtmp
        echo "Please run the command again"
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
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm.sh"
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
            echo "easyrm.sh was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/ermversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/ermversion.txt 2>&1 | grep ERMVER= | tr -d 'ERMVER="')
    if [[ $ERMVER != $VERTEST ]]; then
        echo "Installed version: $ERMVER -- Current version: $VERTEST"
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
        echo "Installed version: $ERMVER -- Current version: $VERTEST"
        echo "easyrm.sh is up to date."
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