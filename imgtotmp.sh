#!/bin/bash
cd /tmp/
IMG=$(xclip -selection o -o)
curl --remote-name $IMG