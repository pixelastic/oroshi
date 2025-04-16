#!/usr/bin/env zsh
# Install GNOME extensions to improve the default Gnome UI

# Install gnome-extensions
echo "Installing extension manager"
sudo apt-get install \
  gnome-shell-extension-manager

local installedExtensions="$(gnome-extensions list)"

# Install Frippery Move Clock {{{
local FRIPPERY_MOVE_CLOCK_URL="https://extensions.gnome.org/extension-data/Move_Clockrmy.pobox.com.v33.shell-extension.zip"
local FRIPPERY_MOVE_CLOCK_ZIP=~/local/tmp/fripperyMoveClock.zip
local FRIPPERY_MOVE_CLOCK_ID="Move_Clock@rmy.pobox.com"

if [[ "$installedExtensions" != *"$FRIPPERY_MOVE_CLOCK_ID"* ]]; then
  # Not yet installed, we install it
  echo ""
  echo ""
  echo "Installing $FRIPPERY_MOVE_CLOCK_ID"

  wget -q $FRIPPERY_MOVE_CLOCK_URL -O $FRIPPERY_MOVE_CLOCK_ZIP
  gnome-extensions install --force $FRIPPERY_MOVE_CLOCK_ZIP

  echo "--------"
  echo "Now, you need to Logout of your session and back in and run this script again to enable the extension."
else
  gnome-extensions enable $FRIPPERY_MOVE_CLOCK_ID
  gnome-extensions info $FRIPPERY_MOVE_CLOCK_ID
fi
# }}}

# Install Hide Universal Access {{{
local HIDE_UNIVERSAL_ACCESS_URL="https://extensions.gnome.org/extension-data/hide-universal-accessakiirui.github.io.v17.shell-extension.zip"
local HIDE_UNIVERSAL_ACCESS_ZIP=~/local/tmp/hideUniversalAccess.zip
local HIDE_UNIVERSAL_ACCESS_ID="hide-universal-access@akiirui.github.io"

if [[ "$installedExtensions" != *"$HIDE_UNIVERSAL_ACCESS_ID"* ]]; then
  # Not yet installed, we install it
  echo ""
  echo ""
  echo "Installing $HIDE_UNIVERSAL_ACCESS_ID"

  wget -q $HIDE_UNIVERSAL_ACCESS_URL -O $HIDE_UNIVERSAL_ACCESS_ZIP
  gnome-extensions install --force $HIDE_UNIVERSAL_ACCESS_ZIP

  echo "--------"
  echo "Now, you need to Logout of your session and back in and run this script again to enable the extension."
else
  gnome-extensions enable $HIDE_UNIVERSAL_ACCESS_ID
  gnome-extensions info $HIDE_UNIVERSAL_ACCESS_ID
fi
# }}}


