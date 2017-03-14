#!/bin/bash
# outputs the history of apt installed packages to ~/packagelist.txt
zcat /var/log/apt/history.log.*.gz | cat - /var/log/apt/history.log | grep -Po '^Commandline: apt install (?!.*--reinstall)\K.*' | tee ~/packagelist.txt
