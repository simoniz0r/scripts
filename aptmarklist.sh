#!/bin/bash
# A script that writes the output apt-mark in alphabetical order to ~/packagelist.txt
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) | tee ~/packagelist.txt
