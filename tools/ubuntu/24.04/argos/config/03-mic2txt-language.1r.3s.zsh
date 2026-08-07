#!/usr/bin/env zsh
# Argos panel widget for mic2txt language status
set -e

local languageName="$(mic2txt-language)"
local iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/mic2txt-language-${languageName}.svg
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
local label="Language: ${languageName} (Click to toggle)"
echo "$label | bash='bin-zsh mic2txt-language-toggle' terminal=false"
