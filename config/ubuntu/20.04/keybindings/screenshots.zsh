#!/usr/bin/env zsh
# Keyboards and shortcuts > Screenshots

# Area > Clipboard
dconf write /org/gnome/settings-daemon/plugins/media-keys/area-screenshot-clip '@as []'
# Area > Save to disk
dconf write /org/gnome/settings-daemon/plugins/media-keys/area-screenshot '@as []'

# Window > Clipboard
dconf write /org/gnome/settings-daemon/plugins/media-keys/window-screenshot-clip '@as []'
# Window > Save to disk
dconf write /org/gnome/settings-daemon/plugins/media-keys/window-screenshot '@as []'

# Screen > Clipboard
dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot-clip '@as []'
# Screen > Save to disk
dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot '@as []'

# Screencast
dconf write /org/gnome/settings-daemon/plugins/media-keys/screencast '@as []'

