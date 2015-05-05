#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Open dash search (need to be set to something else than <Super> so other
# bindings with <Super> can work.
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-launcher "'<Super>space'"
# Disable other Unity dash-related keybindings
dconf write /org/compiz/profiles/unity/plugins/unityshell/keyboard-focus "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-menu-bar "'Disabled'"
dconf write /org/compiz/integrated/show-hud "['disabled']"
dconf write /org/compiz/profiles/unity/plugins/unityshell/panel-first-menu "'Disabled'"

# Disable Unity Alt-Tab switcher
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-forward "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-prev "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-forward "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-prev "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-forward-all "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-prev-all "'Disabled'"

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
dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['disabled']"
# Locking screen
dconf write /org/compiz/profiles/unity/plugins/unityshell/lock-screen "'<Control><Super>L'"
