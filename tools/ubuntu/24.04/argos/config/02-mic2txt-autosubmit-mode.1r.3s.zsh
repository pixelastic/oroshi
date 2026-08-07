#!/usr/bin/env zsh
# Argos panel widget for mic2txt autosubmit mode status
set -e

local iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/mic2txt-autosubmit-mode-disabled.svg
local autosubmitStatus="off"
if mic2txt-autosubmit-mode-is-enabled; then
  autosubmitStatus="on"
  iconPath=~/.oroshi/tools/ubuntu/24.04/argos/config/icons/mic2txt-autosubmit-mode-enabled.svg
fi
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
local label="Autosubmit mode: ${autosubmitStatus} (Click to toggle)"
echo "$label | bash='bin-zsh mic2txt-autosubmit-mode-toggle' terminal=false"
