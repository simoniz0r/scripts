#!/bin/bash
# A simple script that can run apt options to save keystrokes.
# Also has a GUI using 'zenity'; just install 'zenity' to check it out.

APTTVER="1.1.9"
X="v1.1.9 - Added check for 'wget' before running updatecheck."
# ^^ Remember to update these and apttversion.txt every release!
SCRIPTNAME="$0"

noguistart () {
    echo "What would you like to do?"
    echo "1 - Run apt update."
    echo "2 - Run apt upgrade."
    echo "3 - Run apt show."
    echo "4 - Run apt search."
    echo "5 - Run apt install."
    echo "6 - List user installed packages."
    echo "7 - Run apt remove."
    echo "8 - Run apt autoremove."
    echo "9 - Exit."
    read -p "Choice? " -n 1 -r
    echo
    main "$REPLY"
    exit 0
}

zenitystart () {
    TERMPID=$(pgrep -l x-term)
    ZCASENUM=$(kill -9 $TERMPID; zenity --list --cancel-label=Exit --width=450 --height=365 --title=apttool --text="Welcome to apttool v$APTTVER\n\nNote: Some options will launch in a new terminal window.\napttool will relaunch after apt has finished running in the terminal.\n\nWhat would you like to do?" --column="Cases" --hide-header "Update package list and upgrade installed packages" "Show information for a package" "Search for packages in the repos" "List packages installed by $USER" "Install new package(s) from the repos" "Remove installed package(s)" "Autoremove unneeded packages (USE WITH CAUTION)" "Check for updated version of apttool")
    if [[ $? -eq 1 ]]; then
        exit 0
    fi
    ZHEADLESS="1"
    main "$ZCASENUM"
    exit 0
}

main () {
    case $1 in
        1|Update*)
            if [ "$ZHEADLESS" = "0" ]; then
                sudo apt update
                echo
                echo "--Finshed--"
                echo
                noguistart
                exit 0
            fi
            programisinstalled "zenity"
            if [ "$return" = "1" ]; then
                PASSWORD="$(zenity --password --title=apttool)\n"; echo -e $PASSWORD | { sudo -S apt update && echo "--Package list update finished--" || echo "--Package list update failed!--" ; } | zenity --text-info --cancel-label="Main menu" --ok-label="Upgrade packages" --width=800 --height=600
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                else
                    ZHEADLESS="1"
                    main "Upgrade"
                fi
            PASSWORD=""
            fi
            ;;
        Upgrade*)
            x-terminal-emulator -e $SCRIPTNAME ZUPG
            exit 0
            ;;
        ZUPG)
            sudo apt upgrade
            echo
            echo "--Finshed--"
            echo
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit
            ;;
        2)
            sudo apt upgrade
            echo
            echo "--Finshed--"
            echo
            noguistart
            exit 0
            ;;
        3|Show*)
            if [ "$ZHEADLESS" = "1" ]; then
                APTSHOW="$(zenity --entry --title=apttool --text="Input the package to show info for:")"
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                fi
                apt show $APTSHOW | zenity --text-info --title=apttool --cancel-label="Main menu" --ok-label="Exit" --width=800 --height=600
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                else
                    exit 0
                fi
                PASSWORD=""
            else
                read -p "What package would you like to show info for? " APTSHOW
                echo
                apt show $APTSHOW
                echo
                echo "--Finshed--"
                echo
                APTSHOW=""
                noguistart
                exit 0
            fi
            ;;
        4|Search*)
            if [ "$ZHEADLESS" = "1" ]; then
                APTSEARCH="$(zenity --entry --title=apttool --text="Input the package to search for:")"
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                fi
                apt search $APTSEARCH | zenity --text-info --title=apttool --cancel-label="Main menu" --ok-label="Exit" --width=800 --height=600
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                else
                    exit 0
                fi
                PASSWORD=""
            else
                read -p "What package would you like to search for? " APTSEARCH
                echo
                apt search $APTSEARCH
                echo
                echo "--Finshed--"
                echo
                APTSEARCH=""
                noguistart
                exit 0
            fi
            ;;
        Install*)
            x-terminal-emulator -e $SCRIPTNAME ZINS
            exit 0
            ;;
        ZINS)
            read -p "What package(s) would you like to install? " APTINSTALL
            echo
            sudo apt install $APTINSTALL
            echo
            echo "--Finshed--"
            echo
            APTINSTALL=""
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit
            ;;
        5)
            read -p "What package(s) would you like to install? " APTINSTALL
            echo
            sudo apt install $APTINSTALL
            echo
            echo "--Finshed--"
            echo
            APTINSTALL=""
            noguistart
            exit 0
            ;;
        6|List*)
            NUM=$(packagelist | wc -l)
            if [ "$ZHEADLESS" = "1" ]; then
                packagelist | zenity --list --title=apttool --column="List of packages installed by $USER in alphabetical order:" --cancel-label="Main menu" --ok-label="Exit" --width=800 --height=600 --text="Total number of packages installed by $USER: $NUM"
                if [[ $? -eq 1 ]]; then
                    zenitystart
                    exit 0
                else
                    exit 0
                fi
            else
                echo "-- Packages --"
                packagelist
                echo "-- Total number of user installed packages: $NUM --"
                echo
                echo "--Finshed--"
                echo
                NUM=""
                noguistart
                exit 0
            fi
            ;;
        Remove*)
            x-terminal-emulator -e $SCRIPTNAME ZREM
            exit 0
            ;;
        ZREM)
            read -p "What package(s) would you like to remove? " APTREMOVE
            echo
            sudo apt remove $APTREMOVE
            echo
            echo "--Finshed--"
            echo
            APTREMOVE=""
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit
            ;;
        7)
            read -p "What package(s) would you like to remove? " APTREMOVE
            echo
            sudo apt remove $APTREMOVE
            echo
            echo "--Finshed--"
            echo
            APTREMOVE=""
            noguistart
            exit 0
            ;;
        Autoremove*)
            x-terminal-emulator -e $SCRIPTNAME ATO
            exit 0
            ;;
        ATO)
            echo
            echo
            echo "Use with caution! Be sure to read through the packages"
            echo "listed to make sure you do not need them!"
            echo
            echo
            read -p "Are you sure you want to continue? Y/N " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt autoremove
                echo
                echo "--Finshed--"
                echo
            fi
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit 0
            ;;
        8)
            echo
            echo
            echo "Use with caution! Be sure to read through the packages"
            echo "listed to make sure you do not need them!"
            echo
            echo
            sudo apt autoremove
            echo
            echo "--Finshed--"
            echo
            noguistart
            ;;
        9)
            exit 1
            ;;
        Check*)
            programisinstalled "curl"
            if [ "$return" = "1" ]; then
                x-terminal-emulator -e $SCRIPTNAME CHK
                exit 0
            else
                zenity --error --title=apttool --text="curl is not installed; cannot check for updates!"
                zenitystart
                exit 0
            fi
            ;;
        CHK)
            ZHEADLESS="1"
            updatecheck
            ;;
        gui)
            programisinstalled "zenity"
            if [ "$return" = "1" ]; then
                zenitystart
                exit 0
            else
                echo "apttool now has a GUI; install 'zenity' to check it out!"
                echo
                noguistart
                exit 0
            fi
            ;;
        *)
            ZHEADLESS="0"
            echo "apttool - http://www.simonizor.gq/linuxapps"
            programisinstalled "curl"
            if [ "$return" = "1" ]; then
                programisinstalled "wget"
                if [ "$return" = "1" ]; then
                    updatecheck
                fi
            fi
            noguistart
            exit 0
    esac
}

packagelist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { return=0; }
  # return value
}

updatescript () {
cat >/tmp/updatescript.sh <<EOL
runupdate () {
    if [ "$SCRIPTNAME" = "/usr/bin/apttool" ]; then
        wget -O /tmp/apttool.sh "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttool/apttool.sh"
        if [ -f "/tmp/apttool.sh" ]; then
            sudo rm -f $SCRIPTNAME
            sudo mv /tmp/apttool.sh $SCRIPTNAME
            sudo chmod +x $SCRIPTNAME
        else
            read -p "Update Failed! Try again? Y/N " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "apttool.sh was not updated!"
                exit 0
            fi
        fi
    else
        wget -O /tmp/apttool.sh "https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttool/apttool.sh"
        if [ -f "/tmp/apttool.sh" ]; then
            rm -f $SCRIPTNAME
            mv /tmp/apttool.sh $SCRIPTNAME
            chmod +x $SCRIPTNAME
        else
            read -p "Update Failed! Try again? Y/N " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "apttool was not updated!"
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
            echo "apttool was not updated!"
            exit 0
        fi
    fi
}
runupdate
EOL
}

updatecheck () {
    echo "Checking for new version..."
    UPNOTES=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttool/apttversion.txt 2>&1 | grep X= | tr -d 'X="')
    VERTEST=$(curl -v --silent https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/apttool/apttversion.txt 2>&1 | grep APTTVER= | tr -d 'APTTVER="')
    if [[ $APTTVER < $VERTEST ]]; then
        echo "Installed version: $APTTVER -- Current version: $VERTEST"
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
            if [ "$ZHEADLESS" = "1" ]; then
                read -p "Press ENTER to continue"
                nohup $SCRIPTNAME gui
                exit 0
            else
                noguistart
            fi
        fi
    else
        echo "Installed version: $APTTVER -- Current version: $VERTEST"
        echo $UPNOTES
        echo "apttool is up to date."
        echo
         if [ "$ZHEADLESS" = "1" ]; then
            read -p "Press ENTER to continue"
            nohup $SCRIPTNAME gui
            exit 0
        else
            noguistart
        fi
    fi
}

main "$1"