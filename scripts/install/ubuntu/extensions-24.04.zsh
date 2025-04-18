#!/usr/bin/env zsh
# Install GNOME extensions to improve the default Gnome UI

# Install gnome-extensions
echo "Installing extension manager"
sudo apt-get install \
  gnome-shell-extension-manager

local installedExtensions="$(gnome-extensions list)"

# Adding a extension requires to first download the source as a zip file, add
# it, then enable it. Unfortunately, it is required to log out and back in Gnome
# between the install and enable steps. This function will check the state, and
# run the correct part based on if the extension has been installed yet or not
# Usage:
# $ addExtension fripperyMoveClock Move_Clock@rmy.pobox.com https://.../
function addExtension() {
  echo ""
  local extensionName=$1
  local extensionUrl=$2
  local extensionId=$3

  if [[ "$installedExtensions" != *"$extensionId"* ]]; then
    downloadExtension $extensionName $extensionUrl;
  else
    enableExtension $extensionName $extensionId;
  fi
}

# Download an extension from its URL, and add it to the list
# Unfortunately, we cannot activate it right away, we need to logout and login
# back
function downloadExtension() {
  echo ""
  local extensionName=$1
  local extensionUrl=$2
  local downloadPath=~/local/tmp/${extensionName}.zip

  echo "[$extensionName] [1/3] Downloading"
  rm -f $downloadPath
  wget -q $extensionUrl -O $downloadPath

  echo "[$extensionName] [2/3] Installing"
  gnome-extensions install --force $downloadPath

  echo "[$extensionName] Now, log out and back in, and restart the same script"
}

# After a logout/login cycle, we can enable the extension
function enableExtension() {
  local extensionName=$1
  local extensionId=$2

  echo "[$extensionName] [3/3] Enabling"
  gnome-extensions enable $extensionId
  echo ""
  gnome-extensions info $extensionId
}


# Just Perfection
# https://gitlab.gnome.org/jrahmatzadeh/just-perfection
# Includes moving the clock, hiding icons from the topbar
addExtension \
  "justPerfection" \
  "https://extensions.gnome.org/extension-data/just-perfection-desktopjust-perfection.v34.shell-extension.zip" \
  "just-perfection-desktop@just-perfection"

# Unite
# https://github.com/hardpixel/unite-shell
# Merges window title bar with Ubuntu top bar
addExtension \
  "unite" \
  "https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip" \
  "unite@hardpixel.eu"

