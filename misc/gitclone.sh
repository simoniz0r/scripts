#!/bin/bash
# Clones all of simoniz0r's repos
# Remote exec:
# bash -c "$(wget --quiet https://raw.githubusercontent.com/simoniz0r/UsefulScripts/master/misc/gitclone.sh -O -)"

dircheck () {
    if [ -d "$1" ]; then
        read -p "$1 exists; remove before cloning? Y/N "
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            rm -rf "$1" && echo "$1 removed!" || echo "$1 remove failed!"
            GITTHISDIR="1"
        else
            echo "$1 not removed; skipping..."
            GITTHISDIR="0"
        fi
    else
        GITTHISDIR="1"
    fi
}

if [ ! -d "/home/$USER/github" ]; then
    mkdir /home/$USER/github
fi
dircheck "/home/$USER/github/dotfiles"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/dotfiles.git
fi
dircheck "/home/$USER/github/discorddownloader"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/discorddownloader.git
fi
dircheck "/home/$USER/github/UsefulScripts"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/UsefulScripts.git
fi
dircheck "/home/$USER/github/Index"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/Index.git
fi
dircheck "/home/$USER/github/kde-gaps"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/kde-gaps.git
fi
dircheck "/home/$USER/github/WindowsStuff"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/WindowsStuff.git
fi
dircheck "/home/$USER/github/startpage.rwt.git"
if [ "$GETTHISDIR" = "1" ]; then
    cd /home/$USER/github/
    git clone https://github.com/simoniz0r/startpage.rwt.git.git
fi