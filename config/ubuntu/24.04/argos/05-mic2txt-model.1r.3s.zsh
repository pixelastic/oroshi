#!/usr/bin/env zsh

local modelName="$(mic2txt-model)"
local iconPath=~/.oroshi/config/ubuntu/24.04/argos/icons/mic2txt-model-${modelName}.svg
local image=$(cat $iconPath | base64 -w 0)

echo "| image='$image' imageWidth=20"
echo "---"
echo "Model: ${modelName} (Click to toggle) | bash='/home/tim/.oroshi/scripts/bin/audio/mic2txt-model-toggle' terminal=false"
