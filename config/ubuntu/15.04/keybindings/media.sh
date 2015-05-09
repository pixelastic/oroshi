#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Alt-Down / Alt-Up for the volume
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Alt>Down'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Alt>Up'"

# Ctrl-Alt-Down for mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Primary><Alt>Down'"
