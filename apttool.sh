#!/bin/bash
# A simple script that can run apt options to save keystrokes.

main () {
    echo "What would you like to do?"
    echo "1 - Run apt update."
    echo "2 - Run apt upgrade."
    echo "3 - Run apt install."
    echo "4 - Run apt remove."
    echo "5 - Run apt autoremove."
    echo "6 - List user installed packages."
    echo "7 - Exit."
    read -p "Choice? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]; then
        sudo apt update
        echo
        main
    elif [[ $REPLY =~ ^[2]$ ]]; then
        sudo apt upgrade
        echo
        main
    elif [[ $REPLY =~ ^[3]$ ]]; then
        read -p "What package would you like to install? " PACKAGE
        echo
        sudo apt install "$PACKAGE"
        echo
        main
    elif [[ $REPLY =~ ^[4]$ ]]; then
        read -p "What package would you like to remove? " REMOVE
        echo
        sudo apt remove $REMOVE
        echo
        main
    elif [[ $REPLY =~ ^[5]$ ]]; then
        sudo apt autoremove
        echo
        main
    elif [[ $REPLY =~ ^[6]$ ]]; then
        echo "Packages:"
        comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
        echo
        main
    else
        exit 1
    fi
}

echo "Welcome to apt tool."
main