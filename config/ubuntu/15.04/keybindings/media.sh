#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.
#
# Note: I have been unable to launch redshift from these bindings, it does not
# seem to have any effect.
#
# Note: I have been unable to bind the <Alt>Right and <Alt>Left keys.

# Alt-Up and Alt-Down change brightness
dconf write /org/compiz/integrated/command-11 "'xbacklight -inc 20'"
dconf write /org/compiz/integrated/run-command-11 "['<Alt>Up']"
dconf write /org/compiz/integrated/command-12 "'xbacklight -dec 20'"
dconf write /org/compiz/integrated/run-command-12 "['<Alt>Down']"

# Alt-Home and Alt-End to change volume
dconf write /org/compiz/integrated/command-13 "'amixer -D pulse sset Master 3%+'"
dconf write /org/compiz/integrated/run-command-13 "['<Alt>Home']"
dconf write /org/compiz/integrated/command-14 "'amixer -D pulse sset Master 3%-'"
dconf write /org/compiz/integrated/run-command-14 "['<Alt>End']"
# Note: I'm also binding it the more gnome-friendly media keys as a fallback
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Alt>Home'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Alt>End'"
# Alt-Maj-Home to toggle mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Alt><Shift>Home'"
