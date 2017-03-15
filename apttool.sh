#!/bin/bash
# A simple script that can run apt options to save keystrokes.

main () {
    echo "What would you like to do?"
    echo "1 - Run apt update."
    echo "2 - Run apt upgrade."
    echo "3 - Run apt-cache search."
    echo "4 - Run apt install."
    echo "5 - Run apt remove."
    echo "6 - Run apt autoremove."
    echo "7 - List user installed packages."
    echo "8 - Exit."
    read -p "Choice? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]; then
        sudo apt update
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[2]$ ]]; then
        sudo apt upgrade
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[3]$ ]]; then
        read -p "What package would you like to search for? " SEARCH
        echo
        apt-cache search "$SEARCH"
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[4]$ ]]; then
        read -p "What package would you like to install? " INSTALL
        echo
        sudo apt install "$INSTALL"
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[5]$ ]]; then
        read -p "What package would you like to remove? " REMOVE
        echo
        sudo apt remove $REMOVE
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[6]$ ]]; then
        sudo apt autoremove
        echo "Finshed"
        main
    elif [[ $REPLY =~ ^[7]$ ]]; then
        echo "Packages:"
        comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
        echo "Finshed"
        main
    else
        exit 1
    fi
}

echo "Welcome to apt tool."
main