#!/usr/bin/env zsh
# Nautilus overlays are way too big. We'll reduce them by using the 8x8 icon for
# all resolutions

local iconPath="/usr/share/icons/Yaru"
local -a allSizes
allSizes=("8x8" "16x16" "24x24" "32x32" "48x48" "256x256")

# Backup all files on first run
local backupPath="${iconPath}/__backup__/"
if [[ ! -d $backupPath ]]; then
  echo "First run of the script, backuping data"
  sudo mkdir -p $backupPath

  for i in {1..$#allSizes}; do 
    local thisSize=${allSizes[$i]}
    sudo cp -r ${iconPath}/$size ${backupPath}
    sudo cp -r ${iconPath}/${size}@2x ${backupPath}
  done
fi

# Now delete all uptodate emblems
for i in {1..$#allSizes}; do 
  local thisSize=${allSizes[$i]}
  local thisPath="${iconPath}/${thisSize}/emblems/emblem-dropbox-uptodate.png"
  local thisPath2x="${iconPath}/${thisSize}@2x/emblems/emblem-dropbox-uptodate.png"

  sudo rm -f $thisPath $thisPath2x
done



