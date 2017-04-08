#!/bin/bash
# Title: smarter apt; smapt.sh
# Author: simonizor
# URL: http://www.simonizor.gq/scripts
# Dependencies: apt for Ubuntu and Ubuntu flavors
# Description: A simple script that makes apt easier to use by shortening the arguments, run them as root easily, and append '-y'
# Example: './smapt.sh -Suuy' runs 'sudo apt update && sudo apt upgrade -y'

bold=$(tput bold)
normal=$(tput sgr0)
ARG="$1"
INPUT="${@:2}"

helpfunc () {
    echo
    echo "${bold}-l  ${normal} - apt list - ${bold}list${normal} packages based on package names"
    echo "${bold}-se ${normal} - apt search - ${bold}search${normal} in package descriptions"
    echo "${bold}-sh ${normal} - apt show - ${bold}show${normal} package details"
    echo "${bold}-sha${normal} - apt show -a - ${bold}show all${normal} package details"
    echo "${bold}-i  ${normal} - apt install - ${bold}install${normal} packages"
    echo "${bold}-ui ${normal} - apt update && apt install - ${bold}update${normal} packages list and ${bold}install${normal} packages"
    echo "${bold}-r  ${normal} - apt remove - ${bold}remove${normal} packages"
    echo "${bold}-a  ${normal} - apt autoremove - Remove ${bold}automatically${normal} all unused packages"
    echo "${bold}-ud ${normal} - apt update - ${bold}update${normal} list of available packages"
    echo "${bold}-ug ${normal} - apt upgrade - ${bold}upgrade${normal} the system by installing/upgrading packages"
    echo "${bold}-uu ${normal} - apt update && apt upgrade - run apt ${bold}update${normal} and then apt ${bold}upgrade${normal}"
    echo "${bold}-fu ${normal} - apt full-upgrade - ${bold}fully upgrade${normal} the system by removing/installing/upgrading packages"
    echo "${bold}-es ${normal} - apt edit-sources - ${bold}edit the source${normal} information file"
    echo 
    echo "Prepending ${bold}-S${normal} will run any of the previous options as root.  Ex: './smapt.sh -Su'"
    echo
    exit 0
}

main () {
    case $1 in
        --l|-l|l)
            apt list
            ;;
        --se|-se|se)
            apt search "$2"
            ;;
        --sha|-sha|sha)
            apt show -a "$2"
            ;;
        --sh|-sh|sh)
            apt show "$2"
            ;;
        --i|-i|i)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt install "$2" -y
                else
                    sudo apt install "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt install "$2" -y
                else
                    apt install "$2"
                fi
            fi
            ;;
        --ui|-ui|ui)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt update || exit 0
                    sudo apt install "$2" -y
                else
                    sudo apt update || exit 0
                    sudo apt install "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt update || exit 0
                    apt install "$2" -y
                else
                    apt update || exit 0
                    apt install "$2"
                fi
            fi
            ;;
        --r|-r|r)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt remove "$2" -y
                else
                    sudo apt remove "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt remove "$2" -y
                else
                    apt remove "$2"
                fi
            fi
            ;;
        --a|-a|a)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt autoremove "$2" -y
                else
                    sudo apt autoremove "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt autoremove "$2" -y
                else
                    apt autoremove "$2"
                fi
            fi
            ;;
        --ud|-ud|ud)
            if [ "$SUDO" = "1" ]; then
                sudo apt update
            else
                apt update
            fi
            ;;
        --ug|-ug|ug)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt upgrade "$2" -y
                else
                    sudo apt upgrade "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt upgrade "$2" -y
                else
                    apt upgrade "$2"
                fi
            fi
            ;;
        --uu|-uu|uu)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt update || exit 0
                    sudo apt upgrade "$2" -y
                else
                    sudo apt update || exit 0
                    sudo apt upgrade "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt update || exit 0
                    apt upgrade "$2" -y
                else
                    apt update || exit 0
                    apt upgrade "$2"
                fi
            fi
            ;;
        --fu|-fu|fu)
            if [ "$SUDO" = "1" ]; then
                if [ "$YES" = "1" ]; then
                    sudo apt full-upgrade "$2" -y
                else
                    sudo apt full-upgrade "$2"
                fi
            else
                if [ "$YES" = "1" ]; then
                    apt full-upgrade "$2" -y
                else
                    apt full-upgrade "$2"
                fi
            fi
            ;;
        --es|-es|es)
            if [ "$SUDO" = "1" ]; then
                sudo apt edit-sources "$2"
            else
                apt edit-sources "$2"
            fi
            ;;
        *)
            echo "smapt.sh - http://www.simonizor.gq/scripts"
            echo "smarter apt; a bash script that shortens apt's arguments"
            helpfunc
            exit 0
    esac
}


if [ ! "$EUID" -ne 0 ]; then
    echo "Do not run smapt.sh as root."
    helpfunc
    exit 0
fi

case $1 in
    S*)
        SUDO="1"
        ARG="${ARG//[S]}"
        if [ "${ARG: -1}" = "y" ]; then
            ARG="${ARG::-1}"
            YES="1"
        fi
        main "$ARG" "$INPUT"
        ;;
    -S*)
        SUDO="1"
        ARG="${ARG//[-S]}"
        if [ "${ARG: -1}" = "y" ]; then
            ARG="${ARG::-1}"
            YES="1"
        fi
        main "$ARG" "$INPUT"
        ;;
    --S*)
        SUDO="1"
        ARG="${ARG//[--S]}"
        if [ "${ARG: -1}" = "y" ]; then
            ARG="${ARG::-1}"
            YES="1"
        fi
        main "$ARG" "$INPUT"
        ;;
    *)
        SUDO="0"
        if [ "${ARG: -1}" = "y" ]; then
            ARG="${ARG::-1}"
            YES="1"
        fi
        main "$ARG" "$INPUT"
esac