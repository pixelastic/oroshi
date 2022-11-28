#!/usr/bin/env zsh

echo "Install ExtensionManager"
flatpak install flathub com.mattjakeman.ExtensionManager

echo "Install the following extensions:"
echo "- EasyScreenCast"
echo "    => Record screen video and webcam"
echo "- Frippery Move Clock"
echo "    => Move clock on the right of the topbar"
echo "- Unite"
echo "    => Merge the window top bar with the screen topbar"

cdo
g extenstion-man
