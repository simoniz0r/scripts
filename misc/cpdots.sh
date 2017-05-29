#!/bin/bash
# A script copies dotfiles and downloads them fron github
# Dependencies: 'git'
# Written by simonizor 5/27/2017 - http://www.simonizor.gq/scripts

DIR="/home/$USER/github/dotfiles"
dotfiles="
/home/simonizor/.zsh_aliases
/home/simonizor/.zshrc
/home/simonizor/.config/mc/ini
/home/simonizor/packagelist.txt
"

dotrepo="https://github.com/simoniz0r/dotfiles.git"

symlink () {
    if [ -f "$2" ] || [ -d "$2" ]; then
        read -p "$2 exists; delete original? Y/N "
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            rm -rf "$2"
            echo "$2 removed!"
            ln -sr "$1" "$2" && echo "Symlink created to $2" || echo "Failed to create symlink for $2"
        else
            echo "$2 was not removed; skipping..."
        fi
    else
        ln -sr "$1" "$2" && echo "Symlink created to $2" || echo "Failed to create symlink for $2"
    fi
}

cpdotsmain () {
    case $1 in
        -g*|--g*)
            cd $DIR
            cd ..
            rm -rf $DIR
            git clone $dotrepo
            ;;
        -l*|--l*)
            echo "dotfiles:"
            echo "$dotfiles"
            ;;
        -h*|--h*)
            echo "cpdots usage:"
            echo "cpdots   : Copies dotfiles from their orignial locations to $DIR"            
            echo "cpdots -h: Shows this help output"
            echo "cpdots -l: Lists managed dotfiles"
            echo "cpdots -s: Symlinks dotfiles from $DIR to their original locations"
            echo "cpdots -g: Downloads files from repos listed in dotrepos.conf to $DIR using git clone"
            ;;
        -s*|--s*)
            echo "Symlinking dotfiles from $DIR to their original locations..."
            symlink "$DIR/.zsh_aliases" "/home/$USER/.zsh_aliases"
            symlink "$DIR/.zshrc" "/home/$USER/.zshrc"
            symlink "$DIR/ini" "/home/$USER/.config/mc/ini"
            symlink "$DIR/packagelist.txt" "/home/$USER/packagelist.txt"
            ;;
        *)
            for file in $dotfiles; do
            echo "Copying $file..."
            cp $file $DIR/
            done
            ;;
    esac
}

if [ ! -d "$DIR" ]; then
    mkdir /home/$USER/github
    mkdir $DIR
    echo "$DIR has been created."
fi
git --version >/dev/null 2>&1 || { echo "git is not installed; exiting..." ; exit 1 ; }
cpdotsmain "$@"