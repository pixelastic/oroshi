#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Move window on the right/left sides
dconf write /org/compiz/profiles/unity/plugins/grid/left-maximize "'<Super>Left'"
dconf write /org/compiz/profiles/unity/plugins/grid/right-maximize "'<Super>Right'"
# Maximize / minimize windows
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['<Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/maximize "['<Super>Up']"
# Close window
dconf write /org/gnome/desktop/wm/keybindings/close "'<Alt>F4'"
# Circle through windows
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/next-all-key "'<Alt>Tab'"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/prev-all-key "'<Shift><Alt>Tab'"

# Going back to desktop
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-desktop-key "'<Super>D'"
# Locking screen
dconf write /org/compiz/profiles/unity/plugins/unityshell/lock-screen "'<Control><Super>L'"
