#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.
#
# Note: I have been unable to launch redshift from these bindings, it does not
# seem to have any effect.

# Super-PrintScreen for taking a screenshot of an area
dconf write /org/compiz/profiles/unity/plugins/commands/command12 "'gnome-screenshot -c -a'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command12-key "'<Super>Print'"
# Super-Alt-PrintScreen for taking a screenshot of and area and save the file
dconf write /org/compiz/profiles/unity/plugins/commands/command14 "'gnome-screenshot -a'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command14-key "'<Alt><Super>Print'"
# Super-Ctrl-PrintScreen for taking a screenshot of the entire window
dconf write /org/compiz/profiles/unity/plugins/commands/command13 "'gnome-screenshot -c'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command13-key "'<Control><Super>Print'"

# Super-Up and Super-Down change brightness
dconf write /org/compiz/profiles/unity/plugins/commands/command16 "'xbacklight -inc 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command16-key "'<Super>Up'"
dconf write /org/compiz/profiles/unity/plugins/commands/command17 "'xbacklight -dec 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command17-key "'<Super>Down'"

# Alt-Home and Alt-End to change volume
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Super>Right'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Super>Left'"
# Alt-Maj-Home to toggle mute
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Super><Shift>Left'"

# Disable
dconf write /org/compiz/profiles/unity/plugins/commands/command18 "''"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command18-key "'unset'"
dconf write /org/compiz/profiles/unity/plugins/commands/command19 "''"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command19-key "'unset'"
