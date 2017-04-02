#!/bin/bash
# Gets lyrics for artist and song name; will launch GUI if no input and 'zenity' is installed.
# Dependencies: 'curl', 'zenity' (optional; for GUI)
# Idea from https://gist.github.com/febuiles/1549991
# Written by simonizor 4/2/2017

if [ -z "$1" ]; then
	artist=$(zenity --entry --title=Artist --text="Enter the artist name:")
	title=$(zenity --entry --title="Song title" --text="Enter the song title:")
	{ curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; echo "Artist - $artist" ; echo "Title - $title" ; } | zenity --text-info --width=500 --height=500
else
	artist="$1"
	title="$2"
	{ curl -s --get "https://makeitpersonal.co/lyrics" --data-urlencode "artist=$artist" --data-urlencode "title=$title" ; echo "Artist - $artist" ; echo "Title - $title" ; }
fi

