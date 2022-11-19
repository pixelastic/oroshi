#!/usr/bin/env zsh
# Nautilus overlays are way too big. We'll reduce them by using the 8x8 icon for
# all resolutions

local iconPath="/usr/share/icons/Yaru"
local referenceSize="8x8"
local referencePath="${iconPath}/${referenceSize}/emblems/emblem-dropbox-uptodate.png"
local referencePath2x="${iconPath}/${referenceSize}@2x/emblems/emblem-dropbox-uptodate.png"
local -a otherSizes
otherSizes=("16x16" "24x24" "32x32" "48x48" "256x256")

# Backup all files on first run
local backupPath="${iconPath}/__backup__/"
if [[ ! -d $backupPath ]]; then
  echo "First run of the script, backuping data"
  sudo mkdir -p $backupPath

  for i in {1..$#otherSizes}; do 
    local size=${otherSizes[$i]}
    sudo cp -r ${iconPath}/$size ${backupPath}
    sudo cp -r ${iconPath}/${size}@2x ${backupPath}
  done
fi

# Now replace all uptodate emblems with the small version
for i in {1..$#otherSizes}; do 
  local otherSize=${otherSizes[$i]}
  local otherPath="${iconPath}/${otherSize}/emblems/emblem-dropbox-uptodate.png"
  local otherPath2x="${iconPath}/${otherSize}@2x/emblems/emblem-dropbox-uptodate.png"

  sudo cp -f $referencePath $otherPath
  sudo cp -f $referencePath2x $otherPath2x
done



