#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.
#
# Note: I have been unable to launch redshift from these bindings, it does not
# seem to have any effect.
#
# Note: I have been unable to bind the <Alt>Right and <Alt>Left keys.

# Alt-Up and Alt-Down change brightness
dconf write /org/compiz/integrated/command-6 "'xbacklight -inc 20'"
dconf write /org/compiz/integrated/run-command-6 "['<Alt>Up']"
dconf write /org/compiz/integrated/command-7 "'xbacklight -dec 20'"
dconf write /org/compiz/integrated/run-command-7 "['<Alt>Down']"

# Alt-Home and Alt-End to change volume
dconf write /org/compiz/integrated/command-8 "'amixer -D pulse sset Master 3%+'"
dconf write /org/compiz/integrated/run-command-8 "['<Alt>Home']"
dconf write /org/compiz/integrated/command-9 "'amixer -D pulse sset Master 3%-'"
dconf write /org/compiz/integrated/run-command-9 "['<Alt>End']"
# Alt-Maj-Home to toggle mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Alt><Shift>Home'"
