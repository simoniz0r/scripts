#!/bin/bash
# Found here https://obsproject.com/forum/threads/hotkey-to-mute-mic-input.22852/
# Can be used to toggle microphone mute/unmute with pulseaudio

pactl set-source-mute  $(pacmd list-sources|awk '/\* index:/{ print $3 }') toggle