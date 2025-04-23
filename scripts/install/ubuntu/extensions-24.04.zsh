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

# Note:
# I want to add new extensions to this list, how do I do that?
#
# - Go to https://extensions.gnome.org/
# - Fin the extension you need
# - Select the right shell version (`gnome-shell-version` will help)
# - Pick the latest extension version
# - Open the DevTools and grab the .zip url of the file downloaded
# - Add a line below, with:
#   - A name (first argument)
#   - A url (that you picked from above)
#   - A random string as third argument (we need it to be unique for now)
# - Run the current script, it will put a zip file in ~/local/tmp
# - Open that zip file and look for the .uuid key in metadata.json
# - Set that as the last argument
# - Log out
# - Re-run the script


# Just Perfection
# https://gitlab.gnome.org/jrahmatzadeh/just-perfection
# https://extensions.gnome.org/extension/3843/just-perfection/
# Includes moving the clock, hiding icons from the topbar
addExtension \
  "justPerfection" \
  "https://extensions.gnome.org/extension-data/just-perfection-desktopjust-perfection.v34.shell-extension.zip" \
  "just-perfection-desktop@just-perfection"

# Unite
# https://github.com/hardpixel/unite-shell
# https://extensions.gnome.org/extension/1287/unite/ (outdated)
# Merges window title bar with Ubuntu top bar
addExtension \
  "unite" \
  "https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip" \
  "unite@hardpixel.eu"
