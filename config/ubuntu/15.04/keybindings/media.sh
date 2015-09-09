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

# Super-F5 and Super-F6 change brightness
dconf write /org/compiz/profiles/unity/plugins/commands/command16 "'xbacklight -dec 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command16-key "'<Super>F5'"
dconf write /org/compiz/profiles/unity/plugins/commands/command17 "'xbacklight -inc 20'"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command17-key "'<Super>F6'"

# Super-F1, F2 and F3 for the volume
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-mute "'<Super>F1'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-down "'<Super>F2'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/volume-up "'<Super>F3'"

# Disable
dconf write /org/compiz/profiles/unity/plugins/commands/command18 "''"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command18-key "'unset'"
dconf write /org/compiz/profiles/unity/plugins/commands/command19 "''"
dconf write /org/compiz/profiles/unity/plugins/commands/run-command19-key "'unset'"
