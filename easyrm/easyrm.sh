#!/bin/bash
# A bash script that uses 'mv' to move files to '~/.easyrmtmp' and provides arguments to clear out '~/.easyrmtmp'; meant to replace using 'rm' on files and folders in case you aren't sure about deleting them.
# Created by simonizor 3/11/2017

# Update script to use || 's instead of ifs in most places

ERMVER="1.2.5"
X="v1.2.5 - Changed 'grep -q -a' to 'grep -q' so case is not ignored."
# ^^ Remember to update these every release; do not move their line position (eliminate version.txt eventually)!
SCRIPTNAME="$0"
ARG="$1"

helpfunc () {
    echo "easyrm.sh - http://www.simonizor.gq/scripts"
    echo "A script that uses 'mv' to move files to '~/.easyrmtmp' instead of deleting them."
    echo
    echo "Usage: './easyrm.sh /path/to/file', './easyrm.sh /path/to/folder/', or './easyrm.sh -h'"
    echo "Arguments:"
    echo "-h : Shows this help output"
    echo "-u : Check for new version of easyrm.sh."
    echo "-l : Shows list of files in '~/.easyrmtmp'"
    echo "-r : Restore a file from '~/.easyrmtmp'; will find closest matching file/folder and restore it to its original location."
    echo "     Ex: './easyrm.sh -r filename'"
    echo "-d : Deletes a specifc file from '~/.easyrmtmp'; will find closest matching file/folder."
    echo "     Ex: './easyrm.sh -d filename'"
    echo "-c : Removes all files and folders from '~/.easyrmtmp'"
}

easyrm () {
    if [ ! -f "$ARG" ] && [ ! -d "$ARG" ]; then
        echo "$ARG does not exist!"
        exit 1
    fi
    if grep -q "$ARG" ~/.easyrmtmp/movedfiles.conf; then
        echo "$ARG already exists in '~/.easyrmtmp'; remove this file in '~/.easyrmtmp' before proceeding."
        exit 1
    fi
    mv "$ARG" ~/.easyrmtmp/ || { echo "Move failed!" ; exit 0 ; }
    echo "$ARG" >> ~/.easyrmtmp/movedfiles.conf
    echo "$ARG has been moved to '~/.easyrmtmp'!"
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
                    echo "$REALNUM file or folder."
                    echo "File/folder is listed with its original location:"
                else
                    echo "$REALNUM files and/or folders."
                    echo "Files/folders are listed with their original location:"
                fi
                cat ~/.easyrmtmp/movedfiles.conf
                ;;
            -r*|--r*)
                RESTORE="$(grep -a "$2" ~/.easyrmtmp/movedfiles.conf)"
                RESTNUM="$(echo "$RESTORE" | wc -l)"
                if ! grep -q "$2" ~/.easyrmtmp/movedfiles.conf; then
                    echo "File not found in '~/.easyrmtmp'!"
                    exit 1
                fi
                if [[ "$RESTNUM" != "1" ]]; then
                    echo "$RESTNUM results found; refine your input."
                    exit 1
                fi
                if [ -f "$RESTORE" ]; then
                    echo "$RESTORE already exists; remove this file before attempting to restore from ~/.easyrmtmp"
                    exit 1
                fi
                read -p "Restore $2 to $RESTORE? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    mv ~/.easyrmtmp/"$2"* $RESTORE
                else
                    echo "$2 was not restored!"
                    exit 0
                fi
                if [ ! -f "$RESTORE" ] && [ ! -d "$RESTORE" ]; then
                    echo "Restore failed!"
                    exit 1
                fi
                sed -i s:"$RESTORE"::g ~/.easyrmtmp/movedfiles.conf
                sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
                echo "$RESTORE has been restored!"
                ;;
            -d*|--d*)
                DELFILE="$(grep -a "$2" ~/.easyrmtmp/movedfiles.conf)"
                DELNUM="$(echo "$DELFILE" | wc -l)"
                if ! grep -q "$2" ~/.easyrmtmp/movedfiles.conf; then
                    echo "File not found in '~/.easyrmtmp'!"
                    exit 1
                fi
                if [[ "$DELNUM" != "1" ]]; then
                    echo "$DELNUM results found; refine your input."
                    exit 1
                fi
                read -p "Perminantly delete $2 (original location $DELFILE)? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -r ~/.easyrmtmp/"$2"* || { echo "$2 not found in '~/.easyrmtmp'!" ; exit 1 ; }
                else
                    echo "$2 (original location $DELFILE) was not deleted!"
                    exit 0
                fi
                sed -i s:"$DELFILE"::g ~/.easyrmtmp/movedfiles.conf
                sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
                echo "$2 (original location $DELFILE) has been deleted!"
                ;;
            -c*|--c*)
                REALNUM="$(cat ~/.easyrmtmp/movedfiles.conf | wc -l)"
                if [ "$REALNUM" = "0" ]; then
                    echo "No files in ~/.easyrmtmp; exiting..."
                    exit 1
                fi
                if [ "$REALNUM" = "1" ]; then
                    echo "The following file or folder in '~/.easyrmtmp' will be permanently deleted (listed by original location):"
                else
                    echo "The following files and/or folders in '~/.easyrmtmp' will be permanently deleted (listed by original location):"
                fi
                cat ~/.easyrmtmp/movedfiles.conf
                read -p "Continue? Y/N" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    cd ~/.easyrmtmp
                    ls | grep -v 'movedfiles.conf' | xargs rm -rf
                    echo "" > ~/.easyrmtmp/movedfiles.conf
                    sed -i '/^$/d' ~/.easyrmtmp/movedfiles.conf
                    if [ "$REALNUM" = "1" ]; then
                        echo "$REALNUM file or folder has been permanently deleted!"
                    else
                        echo "$REALNUM files and/or folders have been permanently deleted!"
                    fi
                else
                    echo "Files and folders in '~/.easyrmtmp' were not deleted!"
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
    echo "Creating '~/.easyrmtmp' folder for temporary storage of removed files/folders..."
    mkdir ~/.easyrmtmp
    touch ~/.easyrmtmp/movedfiles.conf
    echo "Please run easyrm again"
    echo
fi
main "$ARG" "$2"