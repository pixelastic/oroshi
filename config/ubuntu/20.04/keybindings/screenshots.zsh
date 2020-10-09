#!/usr/bin/env zsh
# Keyboards and shortcuts > Screenshots

dconf write /org/gnome/settings-daemon/plugins/media-keys/area-screenshot "['<Primary><Super>p']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/screencast "['<Super>r']"

dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot-clip '@as []'
dconf write /org/gnome/settings-daemon/plugins/media-keys/window-screenshot '@as []'
dconf write /org/gnome/settings-daemon/plugins/media-keys/window-screenshot-clip '@as []'
