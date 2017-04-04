#!/bin/bash
# Refresh wttr.in every 5 minutes
# Only tested with city name and zipcode; additional location info should work.
# wttrrefresh.sh - http://www.simonizor.gq/scripts
# This script uses 'printf '\e[?25l'' to hide the cursor; use 'reset' after running this script if your cursor is still hidden.

read -p "Input your location: " LOCATION
tput reset
while true
do
    printf '\e[?25l'
    curl "wttr.in/$LOCATION?0?Q"
    sleep 300
    tput reset
done