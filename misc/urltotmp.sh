#!/bin/bash
NAME=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10)
URL=$(xclip -selection o -o)
wget -O /tmp/$NAME.png "$URL"