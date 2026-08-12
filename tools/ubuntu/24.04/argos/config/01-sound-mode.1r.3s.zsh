#!/usr/bin/env zsh
# Argos panel widget for sound mode status
set -e

local iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/sound-mode-disabled.svg
local soundStatus="off"
if sound-mode-is-enabled; then
  soundStatus="on"
  iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/sound-mode-enabled.svg
fi
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
local toggleCmd="bash='bin-zsh sound-mode-toggle' terminal=false"
echo "Sound mode: ${soundStatus} (Click to toggle) | ${toggleCmd}"
