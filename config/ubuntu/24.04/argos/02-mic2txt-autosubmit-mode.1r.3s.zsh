#!/usr/bin/env zsh

local iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-autosubmit-mode-disabled.svg
local autosubmitStatus="off"
if mic2txt-autosubmit-mode-is-enabled; then
  autosubmitStatus="on"
  iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-autosubmit-mode-enabled.svg
fi
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
echo "Autosubmit mode: ${autosubmitStatus} (Click to toggle) | bash='/home/tim/.oroshi/scripts/bin/audio/mic2txt-autosubmit-mode-toggle' terminal=false"
