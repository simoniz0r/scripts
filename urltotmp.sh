#!/bin/bash
cd /tmp/
URL=$(xclip -selection o -o)
curl --remote-name $URL