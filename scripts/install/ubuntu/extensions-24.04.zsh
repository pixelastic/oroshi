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
  local extensionId=$2
  local downloadUrl=$3

  if [[ "$installedExtensions" != *"$extensionId"* ]]; then
    downloadExtension $extensionName $extensionId $downloadUrl;
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
  local extensionId=$2
  local downloadUrl=$3
  local downloadPath=~/local/tmp/${extensionId}.zip

  echo "[$extensionName] [1/3] Downloading"
  rm -f $downloadPath
  wget -q $downloadUrl -O $downloadPath

  echo "[$extensionName] [2/3] Installing"
  gnome-extensions install --force $downloadPath
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


addExtension \
  "fripperyMoveClock" \
  "Move_Clock@rmy.pobox.com" \
  "https://extensions.gnome.org/extension-data/Move_Clockrmy.pobox.com.v33.shell-extension.zip"

addExtension \
  "hideUniversalAccess.zip" \
  "hide-universal-access@akiirui.github.io" \
  "https://extensions.gnome.org/extension-data/hide-universal-accessakiirui.github.io.v17.shell-extension.zip"

