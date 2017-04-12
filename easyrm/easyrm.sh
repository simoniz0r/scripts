#!/bin/bash
# A bash script that uses 'mv' to move files to '~/.easyrmtmp' and provides arguments to clear out '~/.easyrmtmp'; meant to replace using 'rm' on files and folders in case you aren't sure about deleting them.
# Created by simonizor 3/11/2017

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

ERMVER="1.1.3"
X="v1.1.3 - Fixed restore to exit if input is not found."
# ^^ Remember to update these every release; do not move their line position (eliminate version.txt eventually)!
SCRIPTNAME="$0"
ARG="$1"

helpfunc () {
    echo "easyrm.sh - http://www.simonizor.gq/scripts"
    echo "A script that uses 'mv' and 'rm' to move files to '~/.easyrmtmp' instead of deleting them by default."
    echo "Usage: 'easyrm.sh /path/to/file' or 'easyrm.sh /path/to/directory/'"
    echo "Note: Directories must have the trailing '/' or you will receive an error."
    echo "Arguments:"
    echo "-h : Shows this help output"
    echo "-u : Check for new version of easyrm.sh."
    echo "-l : Shows list of files in '~/.easyrmtmp'"
    echo "-r : Restore a file from '~/.easyrmtmp'; will find closest matching file and restore it to its original location."
    echo "-c : Removes all files and directories from '~/.easyrmtmp'"
    echo "-f : Removes all files and directories from '~/.easyrmtmp' by force; use for errors with '-c'."
    echo "-uninstall : Removes '~/.easyrmtmp' directory and config file."
}

easyrm () {
    if [ ! -f "$ARG" ]; then
        echo "$ARG does not exist!"
        exit 0
    fi
    echo "$ARG will be moved to '~/.easyrmtmp'..."
    read -p "Continue? Y/N" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv $ARG ~/.easyrmtmp/
        if [ ! -f ~/.easyrmtmp/$ARG ] && [ ! -f ~/.easyrmtmp/$ORIG ]; then
            echo "Move failed!"
            exit 0
        fi
        echo "$ARG" >> ~/.easyrmtmp/movedfiles.conf
        echo "$ARG has been moved to '~/.easyrmtmp'!"
    else
        echo "$ARG was not moved!"
    fi
}

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    wget -O /tmp/easyrm.sh "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/easyrm.sh"
    if [ ! -f /tmp/easyrm.sh ]; then
        echo "Download failed; try again later!"
        exit 0
    fi
    rm -f $SCRIPTNAME
    mv /tmp/easyrm.sh $SCRIPTNAME
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
    UPNOTES="$(wget -q "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/easyrm.sh" -O - | sed -n '9p' | tr -d 'X="')"
    VERTEST="$(wget -q "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/easyrm/easyrm.sh" -O - | sed -n '8p' | tr -d 'ERMV="')"
    if [[ $ERMVER < $VERTEST ]]; then
        echo "Installed version: $ERMVER -- Current version: $VERTEST"
        echo "A new version is available!"
        echo "$UPNOTES"
        read -p "Would you like to update? Y/N " -n 1 -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
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
        echo "$UPNOTES"
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
    if [[ "$ARG" == /* ]]; then
        easyrm "$ARG"
    elif [[ "$ARG" == ./* ]]; then
        ORIG="${ARG:2}"
        ARG="$PWD/${ARG:2}"
        easyrm "$ARG"
    elif [[ "$ARG" == ~/* ]]; then
        easyrm "$ARG"
    elif [[ "$ARG" == -* ]]; then
        case "$ARG" in
            -l*|--l*)
                REALNUM="$(cat ~/.easyrmtmp/movedfiles.conf | wc -l)"
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp"
                    exit 0
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "$REALNUM file or directory."
                else
                    echo "$REALNUM files and/or directories."
                fi
                cat ~/.easyrmtmp/movedfiles.conf
                ;;
            -r*|--r*)
                RESTORE="$(grep -a "$2" ~/.easyrmtmp/movedfiles.conf)"
                RESTNUM="$(echo "$RESTORE" | wc -l)"
                if ! grep -q -a "$2" ~/.easyrmtmp/movedfiles.conf; then
                    echo "File not found in '~/.easyrmtmp'!"
                    exit 0
                fi
                if [[ "$RESTNUM" != "1" ]]; then
                    echo "$RESTNUM results found; refine your input."
                    exit 0
                fi
                if [ -f "$RESTORE" ]; then
                    echo "$RESTORE already exists; remove this file before attempting to restore from ~/.easyrmtmp"
                    exit 0
                fi
                read -p "Restore $2 to $RESTORE? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    mv ~/.easyrmtmp/"$2"* $RESTORE
                else
                    echo "$2 was not restored!"
                    exit 0
                fi
                if [ ! -f "$RESTORE" ]; then
                    echo "Restore failed!"
                    exit 0
                fi
                sed -i s:"$RESTORE"::g ~/.easyrmtmp/movedfiles.conf
                sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
                echo "$RESTORE has been restored!"
                ;;
            -c*|--c*)
                REALNUM="$(cat ~/.easyrmtmp/movedfiles.conf | wc -l)"
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp; exiting..."
                    exit 0
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "The following file or directory in '~/.easyrmtmp' will be permanently deleted:"
                else
                    echo "The following files and/or directories in '~/.easyrmtmp' will be permanently deleted:"
                fi
                cat ~/.easyrmtmp/movedfiles.conf
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    cd ~/.easyrmtmp
                    ls | grep -v 'movedfiles.conf' | xargs rm -r
                    echo "" > ~/.easyrmtmp/movedfiles.conf
                    sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
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
                REALNUM="$(cat ~/.easyrmtmp/movedfiles.conf | wc -l)"
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
                    cd ~/.easyrmtmp
                    ls | grep -v 'movedfiles.conf' | xargs rm -rf
                    echo "" > ~/.easyrmtmp/movedfiles.conf
                    sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
                    if [ "$REALNUM" = "1" ]; then
                        echo "$REALNUM file or directory has been permanently deleted by force!"
                    else
                        echo "$REALNUM files and/or directories have been permanently deleted by force!"
                    fi
                else
                    echo "Files and directories in '~/.easyrmtmp' were not deleted!"
                fi
                ;;
            -uninstall*|--uninstall*)
                echo "All files in '~/.easyrmtmp' will be permanently deleted and config file will be removed!"
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf ~/.config/easyrm/
                    rm -rf ~/.easyrmtmp/
                    echo "Finished!"
                else
                    echo "'~/.easyrmtmp' was not deleted and config file remains!"
                fi
                ;;
            -u*|--u*)
                programisinstalled "wget"
                if [ "$return" = "1" ]; then
                    updatecheck
                else
                    echo "wget is not installed; cannot check for update!"
                    exit 1
                fi
                ;;
            -*|--*)
                helpfunc
                exit 0
        esac
    elif [ -z "$ARG" ];then
        helpfunc
    else
        ORIG="$ARG"
        ARG="${ARG::-z}$PWD/$ARG"
        easyrm "$ARG"
    fi
}

if [ ! -d ~/.easyrmtmp ]; then
    echo "Directory '~/.easyrmtmp' does not exist..."
    echo "Creating '~/.easyrmtmp' directory for temporary storage of removed files/directories..."
    mkdir ~/.easyrmtmp
    touch ~/.easyrmtmp/movedfiles.conf
    echo "Please run easyrm again"
    echo
fi
main "$ARG" "$2"