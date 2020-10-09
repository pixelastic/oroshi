#!/usr/bin/env zsh
# Keyboards and shortcuts > System
dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Primary><Super>l']"

dconf write /org/gnome/mutter/wayland/keybindings/restore-shortcuts '@as []'
dconf write /org/gnome/shell/keybindings/focus-active-notification '@as []'
dconf write /org/gnome/shell/keybindings/open-application-menu '@as []'
dconf write /org/gnome/shell/keybindings/toggle-application-view '@as []'
dconf write /org/gnome/shell/keybindings/toggle-message-tray '@as []'
dconf write /org/gnome/shell/keybindings/toggle-overview '@as []'
