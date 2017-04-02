#!/bin/bash
# A script that uses 'gpg' to encrypt and decrypt passwords stored in '~/.gpgpassman'.
# Dependencies: 'gpg', 'xclip', 'curl' (optional; for auto-updating gpgpassman), 'zenity' (optional)
# If you have 'zenity' installed, executing 'gpgpassman' will show a full GUI for all of the scripts options.
# Also with 'zenity', you can execuite 'gpgpassman dec' for direct access to decrypting passwords; can be used with a keybind.
# Written by simonizor 3/22/2017 - http://www.simonizor.gq/scripts

GPMVER="1.2.8"
X="v1.2.8 - Added option to backup stored passwords to a different directory."
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
    if [ "$SCRIPTNAME" = "/usr/bin/gpgpassman" ]; then
        wget -O /tmp/gpgpassman.sh "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpgpassman/gpgpassman.sh"
        if [ -f "/tmp/gpgpassman.sh" ]; then
            sudo rm -f /usr/bin/gpgpassman
            sudo mv /tmp/gpgpassman.sh /usr/bin/gpgpassman
            sudo chmod +x /usr/bin/gpgpassman
        else
            read -p "Update Failed! Try again? Y/N " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "gpgpassman was not updated!"
                exit 0
            fi
        fi
    else
        wget -O /tmp/gpgpassman.sh "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpgpassman/gpgpassman.sh"
        if [ -f "/tmp/gpgpassman.sh" ]; then
            rm -f $SCRIPTNAME
            mv /tmp/gpgpassman.sh $SCRIPTNAME
            chmod +x $SCRIPTNAME
        else
            read -p "Update Failed! Try again? Y/N " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "gpgpassman was not updated!"
                exit 0
            fi
        fi
    fi
    if [ -f $SCRIPTNAME ]; then
        echo "Update finished!"
        rm -f /tmp/updatescript.sh
        if type zenity >/dev/null 2>&1; then
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit 0
        else
            exec $SCRIPTNAME
        fi
    else
        read -p "Update Failed! Try again? Y/N " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            runupdate
        else
            echo "gpgpassman was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpgpassman/gpmversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/gpgpassman/gpmversion.txt 2>&1 | grep GPMVER= | tr -d 'GPMVER="')
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
            if [ "$ZHEADLESS" = "1" ]; then
                read -p "Press ENTER to continue"
                nohup $SCRIPTNAME gui
                exit 0
            elif [ "$ZHEADLESS" = "0" ];then
                noguimain
                exit 0
            else
                echo
                echo "gpgpassman was not updated."
            fi
        fi
    else
        if [ "$ZHEADLESS" = "1" ]; then
            echo "Installed version: $GPMVER -- Current version: $VERTEST"
            echo $UPNOTES
            echo "gpgpassman is up to date."
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit 0
        elif [ "$ZHEADLESS" = "0" ];then
            echo "Installed version: $GPMVER -- Current version: $VERTEST"
            echo $UPNOTES
            echo "gpgpassman is up to date."
            noguimain
            exit 0
        else
            echo "Installed version: $GPMVER -- Current version: $VERTEST"
            echo $UPNOTES
            echo "gpgpassman is up to date."
        fi
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
    echo "- Ex: 'gpgpassman add servicename'"
    echo "${bold}dec${normal} - Decrypt a stored password file using the service name and copy to clipboard for 45 seconds."
    echo "- Ex: 'gpgpassman dec servicename'"
    echo "${bold}bac${normal} - Backup your passwords to a new directory."
    echo "- Ex: 'gpgpassman bac /home/simonizor/passwordbackup'"
    echo "- Can also be executed as './gpgpassman dec' to launch a zenity window to input service or launch terminal if zenity is not installed."
    echo "${bold}rem${normal} - Remove a stored password file using the service name."
    echo "- Ex: 'gpgpassman rem servicename'"
    echo "${bold}dir${normal} - Change default directory used by gpgpassman. Only passwords in the currently configured directory will be able to be managed."
    echo "- Ex: './gpgpassman dir /path/to/directory'."
    echo "${bold}gen${normal} - Generate new passwords using 'apg'."
    echo "- Ex: 'gpgpassman gen'"
    echo "${bold}gui${normal} - If 'zenity' is installed, gpgpassman's GUI will be launched."
    echo "- Ex: gpgpassman gui"
}

zenitymain () {
    TERMPID=$(pgrep -l x-term)
    ZMAINCASE=$(kill -9 $TERMPID; zenity --list --cancel-label=Exit --width=540 --height=460 --title=gpgpassman --text="Welcome to gpgpassman v$GPMVER\n\ngpgpassman is a password manager that uses 'gpg' for encryption.\n\nPassword storage directory:\n$GPMDIR\n\nManaged passwords:\n$(dir $GPMDIR)\n\nWhat would you like to do?" --column="Cases" --hide-header "Add a new encrypted password" "Decrypt a stored password" "Backup your stored passwords" "Remove a stored password" "Change password storage directory" "Generate passwords using 'apg'" "Check for gpgpassman update")
    if [[ $? -eq 1 ]]; then
        exit 0
    fi
    ZHEADLESS="1"
    main "$ZMAINCASE"
}

noguimain () {
    echo "What would you like to do?"
    echo "${bold}Add${normal} an encrypted password."
    echo "${bold}Decrypt${normal} a stored password."
    echo "${bold}Backup${normal} your passwords."
    echo "${bold}Remove${normal} a stored password."
    echo "${bold}Change${normal} the default password storage directory."
    echo "${bold}Generate${normal} new passwords using 'apg'."
    echo "${bold}Help${normal}"
    echo "${bold}Exit${normal}"
    read -p "Choice? " -r
    echo
    main "$REPLY"
    exit 0
}

main () {
    case $1 in
        add*|Add*)
            if [ -z $SERVNAME ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    SERVNAME=$(zenity --entry --title=gpgpassman --cancel-label="Main menu" --width=540 --height=460 --text="Add a new encrypted password.\n\nYou will be prompted for two different password inputs.\nThe first is the password that you use to login to the service.\nThe second is the password used for gpg encryption.\n\nYou will be prompted to overwrite already managed services.\n\n\n\n\n\n\n\n\n\n\nEnter the service name to encrypt a password for:")
                    if [[ $? -eq 1 ]]; then
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                else
                    read -p "Input the service name to encrypt a password for: " SERVNAME
                fi
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --question --text="Password for $SERVNAME is already stored; overwrite (clipboard will also be cleared)?" --cancel-label=No --ok-label=Yes
                    if [[ $? -eq 1 ]]; then
                        zenity --warning --text="Password for $SERVNAME was not overwritten."
                        SERVNAME=""
                        zenitymain
                        exit 0
                    else
                        echo -n "$(gpg -d $GPMDIR/$SERVNAME/$SERVNAME.gpg)" | xclip -selection c -i
                        if [ "$(xclip -selection c -o)" = "" ]; then
                            zenity --error --text="Wrong password or gpg failure!"
                            SERVNAME=""
                            main "add"
                            exit 0
                        fi
                        zenity --warning --text="Stored password for $SERVNAME removed"
                        rm -f $GPMDIR/$SERVNAME/$SERVNAME.gpg
                    fi
                else
                    read -p "Password for $SERVNAME is already stored; overwrite (clipboard will also be cleared)? Y/N"
                    if [[ $REPLY =~ ^[Nn]$ ]]; then
                        echo "Password for $SERVNAME was not overwritten."
                        exit 0
                    else
                        echo -n "$(gpg -d $GPMDIR/$SERVNAME/$SERVNAME.gpg)" | xclip -selection c -i
                        if [ "$(xclip -selection c -o)" = "" ]; then
                            echo "Wrong password or gpg failure!"
                            exit 0
                        fi
                        echo -n "Password cleared from clipboard" | xclip -selection c -i
                    fi
                fi
            fi
            if [ -z $SERVNAME ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --timeout=5 --text="No service name entered; try again."
                    SERVNAME=""
                    main "add"
                    exit 0
                else
                    echo "No service name entered; try again."
                    SERVNAME=""
                    main "add"
                    exit 0
                fi
            fi
            if [ "$ZHEADLESS" = "1" ]; then
                PASSINPUT=$(zenity --entry --hide-text --text="Enter your password for $SERVNAME:")
                if [[ $? -eq 1 ]]; then
                    SERVNAME=""
                    zenitymain
                    exit 0
                fi
                PASSINPUT2=$(zenity --entry --hide-text --text="Input password again for $SERVNAME:")
                if [[ $? -eq 1 ]]; then
                    SERVNAME=""
                    zenitymain
                    exit 0
                fi
            else
                echo "Input your password for $SERVNAME:"
                read -s PASSINPUT
                echo
                echo "Input password again for $SERVNAME:"
                read -s PASSINPUT2
                echo
            fi
            if [ "$PASSINPUT" != "$PASSINPUT2" ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --text="Passwords to not match; try again!"
                    SERVNAME=""
                    main "add"
                    exit 0
                else
                    echo "Passwords do not match; try again!"
                    SERVNAME=""
                    main "add"
                    exit 0
                fi
            fi
            if [ ! -d "$GPMDIR" ]; then
                mkdir $GPMDIR
            fi
            if [ ! -d "$GPMDIR/$SERVNAME" ]; then
                mkdir $GPMDIR/$SERVNAME
            fi
            if [ "$ZHEADLESS" = "1" ]; then
                zenity --warning --timeout=5 --text="Enter the password to be used for encryption/decryption:"
            fi
            echo $PASSINPUT | gpg -c -o $GPMDIR/$SERVNAME/$SERVNAME.gpg
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --warning --text="Password for $SERVNAME encrypted in $GPMDIR/$SERVNAME/$SERVNAME.gpg"
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo "Password for $SERVNAME encrypted in $GPMDIR/$SERVNAME/$SERVNAME.gpg"
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --text="Failed to write encrypted file for $SERVNAME in $GPMDIR/$SERVNAME/$SERVNAME.gpg"
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo "Failed to write encrypted file for $SERVNAME in $GPMDIR/$SERVNAME/$SERVNAME.gpg"
                fi
            fi
            ;;
        dec*|Dec*)
            if [ -z "$SERVNAME" ]; then
                if [ $ZHEADLESS = "0" ]; then
                    read -p "Input the service name to decrypt a password for: " SERVNAME
                else
                    programisinstalled "zenity"
                    if [ $return = "1" ];then
                        ZHEADLESS="1"
                        SERVNAME=$(zenity --file-selection --file-filter=*.gpg --title="gpgpassman -- Select the gpg file to decrypt" --filename=$GPMDIR/)
                        if [[ $? -eq 1 ]]; then
                            SERVNAME=""
                            zenitymain
                            exit 0
                        fi
                        ZHEADLESS="1"
                    else
                        read -p "Enter the service name to decrypt password for: " SERVNAME
                    fi
                fi
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then 
                echo "Decrypting password for $SERVNAME"
                sleep 0.5
                echo -n "$(gpg -d $GPMDIR/$SERVNAME/$SERVNAME.gpg)" | xclip -selection c -i
                if [ "$(xclip -selection c -o)" = "" ]; then
                    echo "Wrong password or gpg failure!"
                    exit 0
                fi
                echo "$SERVNAME password copied to clipboard; clipboard will be cleared after 45 seconds..."
                sleep 45
                echo -n "Password cleared from clipboard" | xclip -selection c -i
                echo "Password cleard from clipboard."
            elif [ "$ZHEADLESS" = "1" ]; then
                echo -n "$(gpg -d $SERVNAME)" | xclip -selection c -i
                if [ "$(xclip -selection c -o)" = "" ]; then
                    zenity --error --text="Wrong password or gpg failure!"
                    SERVNAME=""
                    main "dec"
                    exit 0
                fi
                zenity --forms --timeout=45 --text="Copied password to clipboard; clipboard will be cleared after 45 seconds..." --cancel-label="Clear now and return to main" --ok-label="Clear now and close"
                if [[ $? -eq 1 ]]; then
                    echo -n "Password cleared from clipboard" | xclip -selection c -i
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo -n "Password cleared from clipboard" | xclip -selection c -i
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --timeout=5 --text="No password found for $SERVNAME"
                    SERVNAME=""
                    main "dec"
                    exit 0
                fi
                echo "No password found for $SERVNAME"
            fi
            ;;
        rem*|Rem*)
            if [ -z "$SERVNAME" ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    SERVNAME=$(zenity --entry --cancel-label="Main menu" --width=540 --height=460 --title=gpgpassman --text="Remove an encrypted password.\n\nThe password for the service name you enter will be deleted permanently!\nYou will be asked for the gpg encryption password before removal.\n\nPassword storage directory:\n$GPMDIR\n\nManaged services:\n$(dir $GPMDIR)\n\n\n\n\n\nEnter the service name to remove:")
                    if [[ $? -eq 1 ]]; then
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                else
                    read -p "Input the service name for the password you want to remove: " SERVNAME
                fi
            fi
            if [ -f "$GPMDIR/$SERVNAME/$SERVNAME.gpg" ];then
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --question --text="Passwords cannot be recovered; are you sure you want to remove password for $SERVNAME?" --ok-label="Yes"
                    if [[ $? -eq 1 ]]; then
                        zenity --warning --text="Password for $SERVNAME was not removed."
                        SERVNAME=""
                        zenitymain
                        exit 0
                    else
                        echo -n "$(gpg -d $GPMDIR/$SERVNAME/$SERVNAME.gpg)" | xclip -selection c -i
                        if [ "$(xclip -selection c -o)" = "" ]; then
                            zenity --error --text="Wrong password or gpg failure!"
                            SERVNAME=""
                            main "rem"
                            exit 0
                        fi
                        echo -n "Password cleared from clipboard" | xclip -selection c -i
                        rm -rf $GPMDIR/$SERVNAME
                        zenity --warning --text="Password for $SERVNAME was removed!"
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                else
                    read -p "Passwords cannot be recovered; are you sure you want to remove the encrypted password for $SERVNAME? Y/N " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        echo -n "$(gpg -d $GPMDIR/$SERVNAME/$SERVNAME.gpg)" | xclip -selection c -i
                        if [ "$(xclip -selection c -o)" = "" ]; then
                            echo "Wrong password or gpg failure!"
                            exit 0
                        fi
                        echo -n "Password cleared from clipboard" | xclip -selection c -i
                        rm -rf $GPMDIR/$SERVNAME
                        echo "Password for $SERVNAME removed!"
                    else
                        echo "Password for $SERVNAME was not removed."
                    fi
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --timeout=5 --text="No password found for $SERVNAME"
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo "No password found for $SERVNAME"
                fi
            fi
            ;;
        bac*|Bac*)
            if [ -z $SERVNAME ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    SERVNAME=$(zenity --file-selection --directory --title="gpgpassman -- Select a location to back up your passwords")
                    if [[ $? -eq 1 ]]; then
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                else
                    read -p "Input the full directory to backup your passwords to. Ex: '/home/simonizor/passwordbackup': " SERVNAME
                fi
            fi
            if [ "${SERVNAME: -1}" = "/" ]; then
                SERVNAME="${SERVNAME::-1}"
            fi
            if [[ "$SERVNAME" == /* ]]; then
                if [ ! -d $SERVNAME ]; then
                    mkdir $SERVNAME
                    if [ "$ZHEADLESS" = "1" ]; then
                        zenity --warning --timeout=5 --text="$SERVNAME directory created for password backup."
                    else
                        echo "$SERVNAME directory created for password backup."
                    fi
                fi
                cp -r $GPMDIR/* $SERVNAME/
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --warning --timeout=5 --text="Passwords have been backed up to $SERVNAME."
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo "Passwords have been backed up to $SERVNAME."
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --timeout=5 --text="$SERVNAME is not a valid directory; use full directory path. Ex: '/home/simonizor/passwordbackup'"
                    SERVNAME=""
                    main "dir"
                    exit 0
                else
                    echo "$SERVNAME is not a valid directory; use full directory path. Ex: './gpgpassman dir /home/simonizor/passwordbackup'"
                    helpfunc
                fi
            fi
            ;;
        dir*|Change*|change*)
            if [ -z $SERVNAME ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    SERVNAME=$(zenity --file-selection --directory --title="gpgpassman -- Select a new password storage directory")
                    if [[ $? -eq 1 ]]; then
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                    zenity --question --text="Only one directory can be managed by gpgpassman at a time; change password storage directory to $SERVNAME?" --ok-label="Yes"
                    if [[ $? -eq 1 ]]; then
                        SERVNAME=""
                        zenitymain
                        exit 0
                    fi
                else
                    read -p "Input the full directory to change password storage to. Ex: '/home/simonizor/mypasswords': " SERVNAME
                fi
            fi
            if [ "${SERVNAME: -1}" = "/" ]; then
                SERVNAME="${SERVNAME::-1}"
            fi
            if [[ "$SERVNAME" == /* ]]; then
                echo "$SERVNAME" > $GPMCONFDIR/gpgpassman.conf
                if [ ! -d $SERVNAME ]; then
                    mkdir $SERVNAME
                    if [ "$ZHEADLESS" = "1" ]; then
                        zenity --warning --timeout=5 --text="$SERVNAME directory created for gpgpassman storage."
                    else
                        echo "$SERVNAME directory created for gpgpassman storage."
                    fi
                fi
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --warning --timeout=5 --text="gpgpassman storage directory changed to $(< ~/.config/gpgpassman/gpgpassman.conf)"
                    SERVNAME=""
                    zenitymain
                    exit 0
                else
                    echo "gpgpassman storage directory changed to $(< ~/.config/gpgpassman/gpgpassman.conf)"
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --timeout=5 --text="$SERVNAME is not a valid directory; use full directory path. Ex: '/home/simonizor/mypasswords'"
                    SERVNAME=""
                    main "dir"
                    exit 0
                else
                    echo "$SERVNAME is not a valid directory; use full directory path. Ex: './gpgpassman dir /home/simonizor/mypasswords'"
                    helpfunc
                fi
            fi
            ;;
        h*)
            echo "gpgpassman - http://www.simonizor.gq/scripts"
            echo "A script that uses 'gpg' to encrypt and decrypt passwords."
            helpfunc
            echo
            programisinstalled "curl"
            if [ $return = "1" ]; then
                updatecheck
            fi
            ;;
        exit*|Exit*)
            exit 0
            ;;
        Check*)
            programisinstalled "curl"
            if [ "$return" = "1" ]; then
                x-terminal-emulator -e $SCRIPTNAME UPD
                exit 0
            else
                zenity --error --text="'curl' is not installed; cannot check for updates!"
                SERVNAME=""
                zenitymain
                exit 0
            fi
            ;;
        UPD)
            ZHEADLESS="1"
            updatecheck
            ;;
        gui)
            programisinstalled "zenity"
            if [ $return = "1" ]; then
                zenitymain
            else
                echo "gpgpassman - http://www.simonizor.gq/scripts"
                echo "A script that uses 'gpg' to encrypt and decrypt passwords."
                echo "gpgpassman now has a GUI; install 'zenity' to check it out!"
                echo
                noguimain
                echo
                programisinstalled "curl"
                if [ $return = "1" ]; then
                    updatecheck
                fi
            fi
            ;;
        gen*|Gen*)
            programisinstalled "apg"
            if [ "$return" = "1" ]; then
                if [ "$ZHEADLESS" = "1" ]; then
                    main "GEN"
                    exit 0
                else
                    apg -s -a 1 -m 30 -n 4
                    read -p "Press ENTER to continue"
                fi
                if [ "$ZHEADLESS" = "0" ];then
                    noguimain
                    exit 0
                fi
            else
                if [ "$ZHEADLESS" = "1" ]; then
                    zenity --error --title=gpgpassman --text="apg is not installed; cannot generate passwords!"
                    zenitymain
                    exit 0
                else
                    echo "apg is not installed!"
                fi
                if [ "$ZHEADLESS" = "0" ]; then
                    noguimain
                    exit 0
                fi
            fi
            ;;
        GEN)
            ZHEADLESS="0"
            x-terminal-emulator -e $SCRIPTNAME gen
            ZHEADLESS="1"
            nohup $SCRIPTNAME gui
            ;;
        *)
            ZHEADLESS="0"
            noguimain
            SERVNAME=""
            exit 0
    esac
}

if [ ! -f "$GPMCONFDIR/gpgpassman.conf" ]; then
    echo "$GPMCONFDIR does not exist; creating..."
    mkdir $GPMCONFDIR
    mkdir $GPMINITDIR
    echo "$GPMINITDIR" > $GPMCONFDIR/gpgpassman.conf
    echo "$GPMCONFDIR created and config file written; run gpgpassman again."
    exit 0
fi
programisinstalled "gpg"
if [ $return = "1" ]; then
    programisinstalled "xclip"
    if [ $return = "1" ]; then
        main "$1"
    else
        programisinstalled "zenity"
        if [ $return = "1" ]; then
            zenity --error --text="xclip is not installed!"
            exit 0
        fi
        echo "xclip is not installed!"
    fi
else
    programisinstalled "zenity"
    if [ $return = "1" ]; then
        zenity --error --text="gpg is not installed!"
        exit 0
    fi
    echo "gpg is not installed!"
fi
