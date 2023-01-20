#!/usr/bin/env zsh
# Nautilus overlays are way too big.
# We'll reduce them by using custom icons stored in ./icons instead

# We need to have fd installed first
if [[ ! -v commands[fd] ]]; then
  echo "You need to install fd first"
  exit 1
fi

local iconPath="/usr/share/icons/Yaru"
local overwritePath="/home/tim/.oroshi/config/ubuntu/22.04/icons"

for newIcon in $overwritePath/*.png; do
  local iconBasename="${newIcon:t}"

  # Find all icons with the same name and override them
  local existingIcons="$(\
    fd \
    --base-directory=${iconPath} \
    --absolute-path \
    --color=never \
    ${iconBasename}\
  )"

  for oldIcon in ${(f)existingIcons}; do
    sudo cp -f $newIcon $oldIcon
  done
done
