#!/usr/bin/env zsh

local languageName="$(mic2txt-language)"
local iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-language-${languageName}.svg
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
echo "Language: ${languageName} (Click to toggle) | bash='/home/tim/.oroshi/scripts/bin/audio/mic2txt-language-toggle' terminal=false"
