#!/usr/bin/env zsh

local iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/sound-mode-disabled.svg
local soundStatus="off"
if sound-mode-is-enabled; then
  soundStatus="on"
  iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/sound-mode-enabled.svg
fi
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
echo "Sound mode: ${soundStatus} (Click to toggle) | bash='/home/tim/.oroshi/scripts/bin/audio/sound-mode-toggle' terminal=false"
