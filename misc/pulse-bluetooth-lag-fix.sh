#!/bin/bash
# A script to get rid of audio delay when using bluetooth with pulseaudio
# Modified version of : https://askubuntu.com/questions/145935/get-rid-of-0-5s-latency-when-playing-audio-over-bluetooth-with-a2dp

BLUEZCARD="$(pactl list cards | grep 'Name:*..*alsa' | cut -f2 -d':' | tr -d ' ')"
pactl set-card-profile $BLUEZCARD a2dp_sink
pactl set-card-profile $BLUEZCARD headset_head_unit
pactl set-card-profile $BLUEZCARD a2dp_sink
SINK="$(pactl list cards | grep -A 4 'Name:*..*alsa' | grep 'alsa.card =' | cut -f2 -d'"')
pacmd set-default-sink $SINK
