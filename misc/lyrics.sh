#!/bin/bash
# Gets lyrics for artist and song name; will launch GUI if no input and 'zenity' is installed.
# Dependencies: 'curl', 'zenity' (optional; for GUI)
# Idea from https://gist.github.com/febuiles/1549991
# Written by simonizor 4/2/2017

main () {
    if [ -z "$1" ]; then
        programisinstalled "zenity"
        if [ "$return" = "1" ]; then
            artist=$(zenity --entry --title=Artist --text="Enter the artist name:")
            title=$(zenity --entry --title="Song title" --text="Enter the song title:")
            { echo "Artist - $artist" ; echo "Title - $title" ; curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; } | zenity --text-info --width=500 --height=500
        else
            read -p "Artist: " artist
            read -p "Title: " title
            { curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; }
        fi
    elif [[ "$1" == -n* ]]; then
        read -p "Artist: " artist
        read -p "Title: " title
        { curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; }
    else
        artist="$1"
        title="$2"
        { echo "Artist - $artist" ; echo "Title - $title" ; curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; }
    fi
}

programisinstalled () {
  # set to 1 initially
  return=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { return=0; }
  # return value
}

type curl >/dev/null 2>&1 || { echo "'curl' is not installed; cannot fetch lyrics." ; exit 0 ; }
main "$1" "$2"