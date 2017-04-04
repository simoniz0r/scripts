#!/bin/bash
# A bash script that uses 'mv' to move files to '~/.easyrmtmp' and provides arguments to clear out '~/.easyrmtmp'; meant to replace using 'rm' on files and folders in case you aren't sure about deleting them.
# Created by simonizor 3/11/2017

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

ERMVER="1.1.1"
X="v1.1.1 - Output if no files are in ~/.easyrmtmp on '-l'"
# ^^ Remember to update these and ermversion.txt every release!
SCRIPTNAME="$0"

helpfunc () {
    echo "easyrm.sh - http://www.simonizor.gq/scripts"
    echo "A script that uses 'mv' and 'rm' to move files to '~/.easyrmtmp' instead of deleting them by default."
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
    echo "$1 will be moved to '~/.easyrmtmp'..."
    read -p "Continue? Y/N" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv $1 ~/.easyrmtmp/
        echo "$1 has been moved to '~/.easyrmtmp'!"
    else
        echo "$1 was not moved!"
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
  type $1 >/dev/null 2>&1 || { return=0; }
  # return value
}

main () {
    if [[ "$1" == /* ]]; then
        easyrm "$1"
    elif [[ "$1" == ./* ]]; then
        easyrm "$1"
    elif [[ "$1" == ~/* ]]; then
        easyrm "$1"
    elif [[ "$1" == -* ]]; then
        case "$1" in
            -l*|--l*)
                NUMBER=$(ls -l ~/.easyrmtmp | wc -l)
                REALNUM=$(($NUMBER-1))
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp"
                    exit 0
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "$REALNUM file or directory."
                else
                    echo "$REALNUM files and/or directories."
                fi
                dir ~/.easyrmtmp
                ;;
            -c*|--c*)
                NUMBER=$(ls -l ~/.easyrmtmp | wc -l)
                REALNUM=$(($NUMBER-1))
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp; exiting..."
                    exit 0
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "The following file or directory in '~/.easyrmtmp' will be permanently deleted:"
                else
                    echo "The following files and/or directories in '~/.easyrmtmp' will be permanently deleted:"
                fi
                dir ~/.easyrmtmp
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -r ~/.easyrmtmp/*
                    if [ "$REALNUM" = "1" ]; then
                        echo "$REALNUM file or directory has been permanently deleted!"
                    else
                        echo "$REALNUM files and/or directories have been permanently deleted!"
                    fi
                else
                    echo "Files and directories in '~/.easyrmtmp' were not deleted!"
                fi
                ;;
            -f*|--f*)
                NUMBER=$(ls -l ~/.easyrmtmp | wc -l)
                REALNUM=$(($NUMBER-1))
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp; exiting..."
                    exit 0
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "The following file or directory in '~/.easyrmtmp' will be permanently deleted by force:"
                else
                    echo "The following files and/or directories in '~/.easyrmtmp' will be permanently deleted by force:"
                fi
                dir ~/.easyrmtmp
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf ~/.easyrmtmp/*
                    if [ "$REALNUM" = "1" ]; then
                        echo "$REALNUM file or directory has been permanently deleted by force!"
                    else
                        echo "$REALNUM files and/or directories have been permanently deleted by force!"
                    fi
                else
                    echo "Files and directories in '~/.easyrmtmp' were not deleted!"
                fi
                ;;
            -r*|--r*)
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
            -u*|--*)
                programisinstalled "curl"
                if [ "$return" = "1" ]; then
                    updatecheck
                else
                    echo "$PROGRAM is not installed; cannot check for update!"
                    exit 1
                fi
                ;;
            -*|--*)
                helpfunc
                exit 0
        esac
    elif [ -z "$1" ];then
        helpfunc
    else
        ARG="${1::-z}./$1"
        easyrm "$ARG"
    fi
}

if [ ! -f ~/.config/easyrm/easyrm.conf ]; then
    mkdir ~/.config/easyrm/
    echo "'~/.easyrmtmp' has been created." > ~/.config/easyrm/easyrm.conf
    echo "Directory '~/.easyrmtmp' does not exist..."
    echo "Creating '~/.easyrmtmp' directory for temporary storage of removed files/directories..."
    mkdir ~/.easyrmtmp
    echo "Please run easyrm again"
    echo
fi
main "$1"