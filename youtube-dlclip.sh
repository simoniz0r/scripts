#!/bin/bash
URL=$(xclip -selection o -o)
youtube-dl $URL