#!/usr/bin/env zsh
# The following tweaks are accessible through a GUI with gnome-tweaks

# Make sure we have the chrome gnome shell extension then
# We can see all extensions by searching for the Extension app
sudo apt-get install chrome-gnome-shell

echo "Now go activate the following extensions:"
echo "https://extensions.gnome.org/extension/2/move-clock/"
echo "https://extensions.gnome.org/extension/1287/unite/"


dconf write /org/gnome/desktop/interface/enable-animations false
dconf write /org/gnome/shell/extensions/unite/hide-window-titlebars "'both'"
dconf write /org/gnome/shell/extensions/unite/show-window-buttons "'always'"
dconf write /org/gnome/mutter/overlay-key "'F18'"
