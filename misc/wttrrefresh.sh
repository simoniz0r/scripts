#!/bin/bash
# Refresh wttr.in every 5 minutes
# Only tested with city name and zipcode; additional location info should work.
# wttrrefresh.sh - http://www.simonizor.gq/scripts

read -p "Input your location: " LOCATION
tput reset
while true
do
    curl "wttr.in/$LOCATION?0?Q"
    sleep 300
    tput reset
done