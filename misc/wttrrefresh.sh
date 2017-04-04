#!/bin/bash
# Refresh wttr.in/$LOCATION?0?Q (LOCATION="$1") every 5 minutes
# Only tested with city name and zipcode; additional location info should work.
# This script uses 'printf '\e[?25l'' to hide the cursor; use 'reset' after running this script if your cursor is still hidden.
# wttrrefresh.sh - http://www.simonizor.gq/scripts

LOCATION="$1"

wttr (){
    if [ -z "$LOCATION" ]; then
        LOCATION="$location"
    fi
    printf '\e[?25l'
    curl "wttr.in/$LOCATION?0?Q"
    sleep 300
    tput reset
    wttr "$LOCATION"
}

wttr "$LOCATION"