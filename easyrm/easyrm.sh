#!/bin/bash
# A bash script that attempts to make 'rm' easier to use by moving files to '~/.easyrmtmp' by default.
# Created by simonizor 3/11/2017

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

ERMVER="1.0.8"
X="v1.0.8 - Removed '-p'; not needed in this script.  Changed '-f' to remove files in '~/.easyrmtmp' by force instead of removing user inputted files."
# ^^ Remember to update these and ermversion.txt every release!
SCRIPTNAME="$0"

help () {
    echo "Tool that uses 'mv' and 'rm' to move files to '~/.easyrmtmp' instead of deleting them by default."
    echo "Usage: 'easyrm.sh /path/to/file' or 'easyrm.sh /path/to/directory/'"
    echo "Note: Directories must have the trailing '/' or you will receive an error."
    echo "Arguments:"
    echo "-h : Shows this help output"
    echo "-u : Check for new version of easyrm.sh."
    echo "-l : Shows list of files in '~/.easyrmtmp'"
    echo "-c : Removes all files and directories from '~/.easyrmtmp'"
    echo "-f : Removes all files and directories from '~/.easyrmtmp' by force; use for errors with '-c'."
    echo "-r : Removes '~/.easyrmtmp' directory and config file."
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

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    rm -f $SCRIPTNAME
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/easyrm.sh"
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
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/ermversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/ermversion.txt 2>&1 | grep ERMVER= | tr -d 'ERMVER="')
    if [[ $ERMVER < $VERTEST ]]; then
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
            echo "easyrm.sh was not updated."
        fi
    else
        echo "Installed version: $ERMVER -- Current version: $VERTEST"
        echo $UPNOTES
        echo "easyrm.sh is up to date."
    fi
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type $PROGRAM >/dev/null 2>&1 || { return=0; }
  # return value
}

if [ -f ~/.config/easyrm/easyrm.conf ]; then
    ARG=$1
    if [[ "$ARG" == /* ]]; then
        easyrm
    elif [[ "$ARG" == ./* ]]; then
        easyrm
    elif [[ "$ARG" == ~/* ]]; then
        easyrm
    elif [[ "$ARG" == -* ]]; then
        case "$ARG" in
            -l*)
                dir ~/.easyrmtmp
                ;;
            -c*)
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
            -f*)
                NUMBER=$(ls -l ~/.easyrmtmp | wc -l)
                REALNUM=$(($NUMBER-1))
                echo "The following files and/or directories in '~/.easyrmtmp' will be permanently deleted by force:"
                dir ~/.easyrmtmp
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf ~/.easyrmtmp/*
                    echo "$REALNUM files and/or directories have been permanently deleted by force!"
                else
                    echo "Files and directories in '~/.easyrmtmp' were not deleted!"
                fi
                ;;
            -r*)
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
            -u*)
                PROGRAM="curl"
                programisinstalled
                if [ "$return" = "1" ]; then
                    updatecheck
                else
                    echo "$PROGRAM is not installed; cannot check for update!"
                    exit 1
                fi
                ;;
            -*)
                help
                exit 0
        esac
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