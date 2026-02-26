#!/usr/bin/env zsh

local iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-slack-mode-disabled.svg
local slackStatus="off"
if mic2txt-slack-mode-is-enabled; then
  slackStatus="on"
  iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-slack-mode-enabled.svg
fi
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
echo "Slack mode: ${slackStatus} (Click to toggle) | bash='/home/tim/.oroshi/scripts/bin/audio/mic2txt-slack-mode-toggle' terminal=false"
