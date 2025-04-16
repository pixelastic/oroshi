#!/usr/bin/env zsh
# Install GNOME extensions to improve the default Gnome UI

# Install gnome-extensions
sudo apt-get install \
  gnome-shell-extension-manager

local installedExtensions="$(gnome-extensions list)"

# Install Frippery Move Clock {{{
local FRIPPERY_MOVE_CLOCK_URL="https://extensions.gnome.org/extension-data/Move_Clockrmy.pobox.com.v33.shell-extension.zip"
local FRIPPERY_MOVE_CLOCK_ZIP=~/local/tmp/fripperyMoveClock.zip
local FRIPPERY_MOVE_CLOCK_ID="Move_Clock@rmy.pobox.com"

if [[ "$installedExtensions" != *"$FRIPPERY_MOVE_CLOCK_ID"* ]]; then
  # Not yet installed, we install it
  wget $FRIPPERY_MOVE_CLOCK_URL -O $FRIPPERY_MOVE_CLOCK_ZIP
  gnome-extensions install $FRIPPERY_MOVE_CLOCK_ZIP
  echo "--------"
  echo "Now, you need to Logout of your session and back in and run this script again to enable the extension."
else
  gnome-extensions enable $FRIPPERY_MOVE_CLOCK_ID
  gnome-extensions info $FRIPPERY_MOVE_CLOCK_ID
fi
# }}}
