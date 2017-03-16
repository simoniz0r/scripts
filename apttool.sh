#!/bin/bash
# A simple script that can run apt options to save keystrokes.

main () {
    echo "What would you like to do?"
    echo "1 - Run apt update."
    echo "2 - Run apt upgrade."
    echo "3 - Run apt-cache search."
    echo "4 - Run apt show."
    echo "5 - Run apt install."
    echo "6 - Run apt remove."
    echo "7 - Run apt autoremove."
    echo "8 - List user installed packages."
    echo "9 - Exit."
    read -p "Choice? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]; then
        sudo apt update
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[2]$ ]]; then
        sudo apt upgrade
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[3]$ ]]; then
        read -p "What package would you like to search for? " SEARCH
        echo
        apt-cache search $SEARCH
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[4]$ ]]; then
        read -p "What package would you like to show info for? " SHOW
        echo
        apt show $SHOW
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[5]$ ]]; then
        read -p "What package would you like to install? " INSTALL
        echo
        sudo apt install $INSTALL
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[6]$ ]]; then
        read -p "What package would you like to remove? " REMOVE
        echo
        sudo apt remove $REMOVE
        echo
        echo "--Finshed--"
        echo
        main
    elif [[ $REPLY =~ ^[7]$ ]]; then
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
        main
    elif [[ $REPLY =~ ^[8]$ ]]; then
        NUM=$(packagelist | wc -l)
        echo "Packages:"
        packagelist
        echo "Total number of user installed packages: $NUM"
        echo
        echo "--Finshed--"
        echo
        main
    else
        exit 1
    fi
}

packagelist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

echo "Welcome to apt tool."
main