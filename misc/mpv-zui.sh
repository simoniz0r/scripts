#!/bin/bash
# Title: mpv-zui
# Author: simonizor
# URL: http://www.simonizor.gq/scripts
# Dependencies: mpv, zenity
# Description: A simple script that launches a zenity GUI for opening files or urls in mpv.  Also has some useful arguments added that can be easily customized.


SCRIPTNAME="$0"
mpvfile () {
    MPVFILE=$(zenity --entry --cancel-label="Exit mpv-zui" --title=mpv-zui --entry-text="Input a file or click OK to browse for a local file" --text="Input the path to a local file or input a remote url.")
    if [[ $? -eq 1 ]]; then
        exit 0
    fi
    if [ "$MPVFILE" = "Input a file or click OK to browse for a local file" ]; then
        MPVFILE=$(zenity --file-selection --filename="/home/$USER/")
        if [[ $? -eq 1 ]]; then
            exit 0
        fi
    fi
    mpvargs
}

mpvargs () {
# This doesn't work because zenity; figure out how to fix it to make more convenient:    MPVARGS=$(zenity --list --multiple --editable --text="Select arguments to run mpv with" --title="mpv-zui" --column="Arguments" "--vo=opengl" "--hwdec=vaapi") # List commonly used arguments for selection, maybe have it be editable with a couple of blank entries that can be custom arguments
    MPVARGS=$(zenity --entry --title=mpv-zui --cancel-label="List options" --text="Input the arguments that you would like to run mpv with:" --entry-text="--border=yes --vo=opengl --hwdec=vaapi --cache=no --cache-pause=no --cache-secs=0")
        if [[ $? -eq 1 ]]; then
            mpv --list-options | zenity --text-info --cancel-label="Exit mpv-zui" --ok-label="Back" --width=710 --height=600 && mpvargs
        if [[ $? -eq 1 ]]; then
            exit 0
        fi
    fi
    mpvrun
}

mpvrun () {
    mpv $MPVARGS "$MPVFILE"
    MPVARGS=""
    MPVFILE=""
    mpvfile
}

programisinstalled () { # check if inputted program is installed using 'type'
    return=1
    type "$1" >/dev/null 2>&1 || { return=0; }
}

programisinstalled "zenity"
if [ "$return" = "1" ]; then
    programisinstalled "mpv"
    if [ "$return" = "1" ]; then
        mpvfile
    else
        echo "mpv is not installed!"
    fi
else
    echo "zenity is not installed!"
fi