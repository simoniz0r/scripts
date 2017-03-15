#!/bin/bash
# A script that outputs the results of apt-mark in alphabetical order.
# Provides arguments to write the output to a file and list number of installed packages.
# Can also install packages from the outputted file.
# Base command found here: http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages

aptmarklist () {
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

help () {
    echo "Outputs the result of apt-mark in alphabetical order by default."
    echo "Arguments:"
    echo "-h : Shows this help dialog."
    echo "-w : Writes the output to ~/.packagelist.txt"
    echo "-c : Write output to custom file. Ex: 'aptmarklist.sh -c ~/mypackages.txt'"
    echo "-n : Outputs the number of user installed packages."
    echo "-i : Installs packages from package list file. Use full path name.  Ex: aptmarklist.sh -i /home/simonizor/packagelist.txt"
}

ARG=$1
if [[ "$ARG" == -* ]]; then
    while getopts ":hwcni" opt; do
        case "$opt" in
        h|\?|help)
            help
            exit 0
            ;;
        w)
            aptmarklist | tee ~/packagelist.txt
            ;;
        c)
            OUTPUT=$2
            aptmarklist | tee $OUTPUT
            ;;
        n)
            aptmarklist | wc -l
            ;;
        i)
            PACKAGELIST=$2
            xargs -a <(awk '/^\s*[^#]/' "$PACKAGELIST") -r -- sudo apt install
        esac
    done
else
    aptmarklist
fi