#!/bin/bash
# Title: smarter apt; smapt.sh
# Author: simonizor
# URL: http://www.simonizor.gq/scripts
# Dependencies: apt for Ubuntu and Ubuntu flavors
# Description: A simple script that adds aliases to make apt easier to use by shortening the arguments, run them as root easily, and append '-y'
# Example: 'apt-Suuy' runs 'sudo apt update && sudo apt upgrade -y'
# Running this script will create '~/.smapt_aliases' which will be loaded through your ~/.bashrc or ~/.zshrc; running it again will replace '~/.smapt_aliases'
# Remote install:
# via wget:
# bash -c "$(wget https://rawgit.com/simoniz0r/UsefulScripts/master/misc/smapt.sh -O -)" && $SHELL
# via curl:
# bash -c "$(curl -fsSL https://rawgit.com/simoniz0r/UsefulScripts/master/misc/smapt.sh)" && $SHELL

addaliases () {
cat >~/.smapt_aliases <<EOL
alias apt-help='smapt'
alias apt-l='apt list'
alias apt-la='apt list -a'
alias apt-lu='apt list --upgradeable'
alias apt-se='apt search'
alias apt-sh='apt show'
alias apt-sha='apt show -a'
alias apt-m='apt-mark'
alias apt-msa='apt-mark showauto'
alias apt-msm='apt-mark showmanual'
alias apt-msu="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
alias apt-msd="comm -23 <(apt-mark showauto | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
alias apt-plw="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) | tee "
alias apt-Si='sudo apt install'
alias apt-Sif='sudo apt install -f'
alias apt-Siy='sudo apt install -y'
alias apt-Sify='sudo apt install -y -f'
alias apt-Sui='sudo apt update && sudo apt install'
alias apt-Suiy='sudo apt update && sudo apt install -y'
alias apt-Sr='sudo apt remove'
alias apt-Srp='sudo apt remove --purge'
alias apt-Sry='sudo apt remove -y'
alias apt-Srpy='sudo apt remove -y --purge'
alias apt-Sa='sudo apt autoremove'
alias apt-Say='sudo apt autoremove -y'
alias apt-Sud='sudo apt update && apt list --upgradeable'
alias apt-Sug='sudo apt upgrade'
alias apt-Sugy='sudo apt upgrade -y'
alias apt-Suu='sudo apt update && sudo apt upgrade'
alias apt-Suuy='sudo apt update && sudo apt upgrade -y'
alias apt-Sfu='sudo apt full-upgrade'
alias apt-Sfuy='sudo apt full-upgrade -y'
alias apt-Sar='sudo apt-add-repository'
alias apt-Sary='sudo apt-add-repository -y'
alias apt-Ses='sudo apt edit-sources'
alias smapt-update="rm -f ~/.smapt_aliases && wget -O ~/.smapt_aliases "https://github.com/simoniz0r/UsefulScripts/raw/master/misc/.smapt_aliases" && $SHELL"
alias smapt-uninstall="rm -f ~/.smapt_aliases && $SHELL"

smapt () {
    echo
    echo "smapt - http://www.simonizor.gq/scripts"
    echo "smarter apt; a set of aliases that shorten apt's arguments"
    echo
    echo "smapt   - Show this help output (alias: apt-help)"
    echo "apt-l   - apt list - list packages based on package names"
    echo "apt-la  - apt list -a - list all versions of packages based on package names"
    echo "apt-lu  - apt list --upgradeable - list packages that have available upgrades"
    echo "apt-se  - apt search - search in package descriptions"
    echo "apt-sh  - apt show - show package details"
    echo "apt-sha - apt show -a - show all package details"
    echo "apt-m   - apt-mark - simple command line interface for marking packages as manually or automatically installed"
    echo "apt-msa - apt-mark showauto - Print the list of automatically installed packages"
    echo "apt-msm - apt-mark showmanual - Print the list of manually installed packages"
    echo "apt-msu - apt-mark showmanual - Print the list of user installed packages"
    echo "apt-msd - apt-mark showauto - Print the list of user packages that were installed as dependencies"
    echo "apt-plw - apt-mark showmanual - Write user installed package list to specified file"
    echo "apt-Si  - sudo apt install - install packages"
    echo "apt-Sif - sudo apt install -f - force dependencies to be installed for failed dpkg install"
    echo "apt-Sui - sudo apt update && sudo apt install - update packages list and install packages"
    echo "apt-Sr  - sudo apt remove - remove packages"
    echo "apt-Srp - sudo apt remove --purge - remove packages and files related to them (configs, etc)"
    echo "apt-Sa  - sudo apt autoremove - Remove automatically all unused packages"
    echo "apt-Sud - sudo apt update - update list of available packages"
    echo "apt-Sug - sudo apt upgrade - upgrade the system by installing/upgrading packages"
    echo "apt-Suu - sudo apt update && sudo apt upgrade - run apt update and then apt upgrade"
    echo "apt-Sfu - sudo apt full-upgrade - fully upgrade the system by removing/installing/upgrading packages"
    echo "apt-Sar - sudo apt-add-repository - apt-add-repository is a script for adding apt sources.list entries"
    echo "apt-Ses - sudo apt edit-sources - edit the source information file"
    echo 
    echo "Appedning 'y' will add '-y' to any of the relevant arguments."
    echo "Ex: 'apt-Siy packagename' runs 'sudo apt install -y packagename'"
    echo
    echo "smapt-update    - Update ~/.smapt_aliases from the github repo using 'wget'"
    echo "smapt-uninstall - Remove ~/.smapt_aliases and restart $SHELL"
    echo
}
EOL
}

loadaliases () {
cat >>~/$RCFILE <<EOL


if [ -f ~/.smapt_aliases ]; then
    . ~/.smapt_aliases
fi
EOL
}

if [ -f ~/.zshrc ]; then
    RCFILE=".zshrc"
    if grep -q -a 'smapt_aliases' ~/.zshrc; then
        echo "smapt aliases added to .zshrc!"
    else
        loadaliases
        if grep -q -a 'smapt_aliases' ~/.zshrc; then
            echo "smapt aliases added to .zshrc!"
        fi
    fi
fi
RCFILE=".bashrc"
addaliases
if grep -q -a 'smapt_aliases' ~/.bashrc; then
    echo "smapt aliases added to .bashrc!"
else
    loadaliases
    if grep -q -a 'smapt_aliases' ~/.bashrc; then
        echo "smapt aliases added to .bashrc!"
        exit 0
    fi
fi