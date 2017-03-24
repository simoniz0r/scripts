#!/bin/bash
# A script that uses 'gpg' to encrypt and decrypt passwords stored in '~/.gpgpassman'.
# Dependencies: 'gpg', 'xclip', 'curl' (optional; for auto-updating gpgpassman.sh), 'zenity' (optional; for executing decrypt outside of terminal)
# Written by simonizor 3/22/2017 - http://www.simonizor.gq/scripts

GPMVER="1.0.7"
X="v1.0.7 - Added zenity to decrypt passwords without launching terminal; executing './gpgpassman.sh dec' will launch a zenity window to input the service to decrypt password for."
# ^^Remember to update this and gpmversion.txt every release!
SCRIPTNAME="$0"
GPMDIR="$(< ~/.config/gpgpassman/gpgpassman.conf)"
GPMINITDIR=~/.gpgpassman
GPMCONFDIR=~/.config/gpgpassman
SERVNAME="$2"
bold=$(tput bold)
normal=$(tput sgr0)

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    rm -f $SCRIPTNAME
    wget -O $SCRIPTNAME "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpgpassman.sh"
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
            echo "gpgpassman.sh was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpmversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpmversion.txt 2>&1 | grep GPMVER= | tr -d 'GPMVER="')
    if [[ $GPMVER < $VERTEST ]]; then
        echo "Installed version: $GPMVER -- Current version: $VERTEST"
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
            echo "gpgpassman.sh was not updated."
        fi
    else
        echo "Installed version: $GPMVER -- Current version: $VERTEST"
        echo $UPNOTES
        echo "gpgpassman.sh is up to date."
    fi
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type "$1" >/dev/null 2>&1 || { return=0; }
  # return value
}

helpfunc () {
    echo "Currently managed services: $(dir $GPMDIR)"
    echo "Current password storage directory: $GPMDIR"
    echo
    echo "${bold}Usage:"
    echo "${bold}add${normal} - Add encrypted password file."
    echo "- Ex: './gpgpassman.sh add servicename'"
    echo "${bold}dec${normal} - Decrypt a stored password file using the service name and copy to clipboard for 45 seconds."
    echo "- Ex: './gpgpassman.sh dec servicename'"
    echo "${bold}rem${normal} - Remove a stored password file using the service name."
    echo "- Ex: './gpgpassman.sh rem servicename'"
    echo "${bold}dir${normal} - Change default directory used by gpgpassman.sh. Only passwords in the currently configured directory will be able to be managed."
    echo "- Ex: './gpgpassman.sh dir /path/to/directory'."
}

main () {
    case $1 in
        add)
            if [ -z $SERVNAME ]; then
                helpfunc
                exit 0
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then
                read -p "Password for $SERVNAME is already stored; overwrite?"
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    echo "Password for $SERVNAME was not overwritten."
                    exit 0
                fi
            fi
            echo "Input your password for $SERVNAME:"
            read -s PASSINPUT
            echo
            echo "Input password again for $SERVNAME:"
            read -s PASSINPUT2
            echo
            if [ "$PASSINPUT" != "$PASSINPUT2" ]; then
                echo "Passwords do not match; try again!"
                exit 0
            fi
            if [ ! -d "$GPMDIR" ]; then
                mkdir $GPMDIR
            fi
            if [ ! -d "$GPMDIR/$SERVNAME" ]; then
                mkdir $GPMDIR/$SERVNAME
            fi
            echo $PASSINPUT | tee $GPMDIR/$SERVNAME/$SERVNAME &>/dev/null
            gpg -c $GPMDIR/$SERVNAME/$SERVNAME
            rm $GPMDIR/$SERVNAME/$SERVNAME
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ]; then
                echo "Password for $SERVNAME encrypted in $GPMDIR/$SERVNAME/$SERVNAME.gpg"
            else
                echo "Failed to write encrypted file!"
            fi
            ;;
        dec*)
            if [ -z "$SERVNAME" ]; then
                programisinstalled "zenity"
                if [ $return = "1" ];then
                    SERVNAME=$(zenity --entry Service)
                else
                    read -p "Enter the service name to decrypt password for: " SERVNAME
                fi
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then 
                echo "Decrypting password for $SERVNAME"
                gpg $GPMDIR/$SERVNAME/$SERVNAME.gpg
                if [ -f "$GPMDIR/$SERVNAME/$SERVNAME" ];then 
                    echo "Copying password to clipboard for 45 seconds..."
                    echo -n "$(cat $GPMDIR/$SERVNAME/$SERVNAME)" | xclip -selection c -i &>/dev/null
                    rm $GPMDIR/$SERVNAME/$SERVNAME
                    sleep 45
                    echo -n "Password cleared from clipboard" | xclip -selection c -i
                    echo "Password cleard from clipboard."
                else
                    echo "Wrong password or gpg closed before decryption finished!"
                fi
            else
                echo "No password found for $SERVNAME"
            fi
            ;;
        rem*)
            if [ -z "$SERVNAME" ]; then
                helpfunc
                exit 0
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then
                read -p "Are you sure you want to remove the encrypted password for $SERVNAME? Y/N " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf $GPMDIR/$SERVNAME
                    echo "Password for $SERVNAME removed!"
                else
                    echo "Password for $SERVNAME was not removed."
                fi
            else
                echo "No password stored for $SERVNAME"
            fi
            ;;
        dir*)
            if [ -z $SERVNAME ]; then
                helpfunc
                exit 0
            fi
            if [ "${SERVNAME: -1}" = "/" ]; then
                SERVNAME="${SERVNAME::-1}"
            fi
            if [[ "$SERVNAME" == /* ]]; then
                echo "$SERVNAME" > $GPMCONFDIR/gpgpassman.conf
                echo "gpgpassman storage directory changed to $(< ~/.config/gpgpassman/gpgpassman.conf)"
                if [ ! -d $SERVNAME ]; then
                    mkdir $SERVNAME
                    echo "$SERVNAME directory created for gpgpassman storage."
                fi
            else
                echo "$SERVNAME is not a valid directory; use full directory path. Ex: './gpgpassman.sh dir /home/simonizor/mypasswords'"
                helpfunc
            fi
            ;;
        *)
            echo "gpgpassman.sh - http://www.simonizor.gq/scripts"
            echo "A script that uses 'gpg' to encrypt and decrypt passwords."
            helpfunc
            echo
            programisinstalled "curl"
            if [ $return = "1" ]; then
                updatecheck
            fi
    esac
}

if [ ! -f "$GPMCONFDIR/gpgpassman.conf" ]; then
    echo "$GPMCONFDIR does not exist; creating..."
    mkdir $GPMCONFDIR
    echo "$GPMINITDIR" > $GPMCONFDIR/gpgpassman.conf
    echo "$GPMCONFDIR created and config file written; run gpgpassman.sh again."
    exit 0
fi
programisinstalled "gpg"
if [ $return = "1" ]; then
    programisinstalled "xclip"
    if [ $return = "1" ]; then
        main "$1"
    else
        echo "xclip is not installed!"
    fi
else
    echo "gpg is not installed!"
fi
