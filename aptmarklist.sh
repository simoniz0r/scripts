#!/bin/bash
# A script that writes the output apt-mark in alphabetical order to ~/packagelist.txt
# Found here: http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) | tee ~/packagelist.txt
