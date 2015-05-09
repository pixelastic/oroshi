#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Alt-Up and Alt-Down change brightness
dconf write /org/compiz/integrated/command-8 "'xbacklight -inc 20'"
dconf write /org/compiz/integrated/run-command-8 "['<Alt>Up']"
dconf write /org/compiz/integrated/command-9 "'xbacklight -dec 20'"
dconf write /org/compiz/integrated/run-command-9 "['<Alt>Down']"

# Alt-Left and Alt-Right for the volume
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Alt>Left'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Alt>Right'"
# Alt-Home for mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Alt>Home'"
