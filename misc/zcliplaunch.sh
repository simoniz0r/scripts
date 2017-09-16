#!/bin/bash 
# Open things on your clipboard with the program of your choice
# Written by simonizor https://www.simonizor.gq
# License: GPL v2 Only

APPS="/usr/bin/mpv
/usr/bin/youtube-dl"

APP_SELECTION="$(zenity --list --title="zcliplaunch" --height="500" --width="350" --column="" --hide-header --text="Select a program to open $(echo -e $(xclip -selection c -o)) with:" $(echo -e "$APPS"))"

"$APP_SELECTION" "$(echo -e $(xclip -selection c -o))"

exit 0
