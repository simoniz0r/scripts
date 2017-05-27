#!/bin/bash
# Refresh wttr.in/$LOCATION?0?Q (LOCATION="$1") every 5 minutes
# Only tested with city name and zipcode; additional location info should work.
# Displays only current weather by default; use './wttrrefresh.sh f LOCATION' to get the full output; $location will be used if no LOCATION is input.
# This script uses 'printf '\e[?25l'' to hide the cursor; use 'reset' after running this script if your cursor is still hidden.
# wttrrefresh.sh - http://www.simonizor.gq/scripts

LOCATION="$1"
FLOCATION="$2"

wttr (){
    case $1 in
        f*)
            if [ -z "$FLOCATION" ]; then
                FLOCATION="$location"
            fi
            printf '\e[?25l'
            curl "wttr.in/$FLOCATION"
            sleep 300
            tput reset
            wttr f "$FLOCATION"
            ;;
        *)
            if [ -z "$LOCATION" ]; then
                LOCATION="$location"
            fi
            printf '\e[?25l'
            echo
            echo
            echo
            echo # remove these or add more to adjust spacing
            curl "wttr.in/$LOCATION?0?Q"
            sleep 300
            tput reset
            wttr "$LOCATION"
    esac
}

wttr "$LOCATION" "$FLOCATION"