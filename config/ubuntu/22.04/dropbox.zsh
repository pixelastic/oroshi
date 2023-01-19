#!/usr/bin/env zsh
# Nautilus overlays are way too big. We'll reduce them by using a custom icon
# instead

local iconPath="/usr/share/icons/Yaru"
local allSizes=("24x24" "32x32" "48x48" "256x256")

# Overwrite the icons with our modified one
local sourcePath="/home/tim/.oroshi/config/ubuntu/22.04/icons/emblem-default.png"
for size in $allSizes; do
  local thisPath="${iconPath}/${size}/emblems/emblem-default.png"
  local thisPath2x="${iconPath}/${size}@2x/emblems/emblem-default.png"

  sudo cp -f $sourcePath $thisPath
  sudo cp -f $sourcePath $thisPath2x
done



