#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.
#
# Note: I have been unable to launch redshift from these bindings, it does not
# seem to have any effect.
#
# Note: I have been unable to bind the <Alt>Right and <Alt>Left keys.

# Super-PrintScreen for taking a screenshot and an area
dconf write /org/compiz/profiles/unity/plugins/commands/command12 "'gnome-screenshot -c -a'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command12-key "'<Super>Print'"
# Super-Ctrl-PrintScreen for taking a screenshot of the current window
dconf write /org/compiz/profiles/unity/plugins/commands/command13 "'gnome-screenshot -c -w -B'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command13-key "'<Control><Super>Print'"
# Super-Ctrl-Alt-PrintScreen for taking a screenshot of the entire screen
dconf write /org/compiz/profiles/unity/plugins/commands/command14 "'gnome-screenshot -c'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command14-key "'<Control><Alt><Super>Print'"

# Alt-Up and Alt-Down change brightness
dconf write /org/compiz/profiles/unity/plugins/commands/command15 "'xbacklight -inc 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command15-key "'<Alt>Up'"
dconf write /org/compiz/profiles/unity/plugins/commands/command16 "'xbacklight -dec 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command16-key "'<Alt>Down'"

# Alt-Home and Alt-End to change volume
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Alt>Home'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Alt>End'"
# Alt-Maj-Home to toggle mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Alt><Shift>Home'"
