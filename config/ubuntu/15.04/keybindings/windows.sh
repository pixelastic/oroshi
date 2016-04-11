#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Close window
dconf write /org/gnome/desktop/wm/keybindings/close "'<Alt>F4'"

# Going back to desktop
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-desktop-key "'<Super>D'"
dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['disabled']"

# Locking screen
dconf write /org/compiz/profiles/unity/plugins/unityshell/lock-screen "'<Control><Super>L'"

# Open dash search (need to be set to something else than <Super> so other
# bindings with <Super> can work.
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-launcher "'<Super>space'"
# Disable other Unity dash-related keybindings
dconf write /org/compiz/profiles/unity/plugins/unityshell/keyboard-focus "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/show-menu-bar "'Disabled'"
dconf write /org/compiz/integrated/show-hud "['disabled']"
dconf write /org/compiz/profiles/unity/plugins/unityshell/panel-first-menu "'Disabled'"

# Circle through windows
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/next-all-key "'<Alt>Tab'"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/prev-all-key "'<Shift><Alt>Tab'"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/opacity "10"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/highlight-mode "1"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/focus-on-switch "true"
dconf write /org/compiz/profiles/unity/plugins/staticswitcher/bring-to-front "true"
# Disable Unity Alt-Tab switcher
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-forward "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-prev "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-forward "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-prev "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-forward-all "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/unityshell/alt-tab-prev-all "'Disabled'"

# Move window to right/left/top/bottom grid with Super-Alt-Arrows
dconf write /org/compiz/profiles/unity/plugins/grid/put-left-key "'<Super><Alt>Left'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-right-key "'<Super><Alt>Right'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-top-key "'<Super><Alt>Up'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-bottom-key "'<Super><Alt>Down'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-topleft-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-topright-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-bottomleft-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-bottomright-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/left-maximize "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/right-maximize "'Disabled'"
# Maximize/Restore with Super-Alt-(Home/End)
dconf write /org/compiz/profiles/unity/plugins/grid/put-maximize-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/grid/put-restore-key "'Disabled'"
dconf write /org/gnome/desktop/wm/keybindings/maximize "['<Alt><Super>Home']"
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['<Alt><Super>End']"

# Move window accross screens
dconf write /org/compiz/profiles/unity/plugins/put/put-next-output-key "'<Super>Return'"
dconf write /org/compiz/profiles/unity/plugins/put/put-previous-output-key "'Disabled'"
dconf write /org/compiz/profiles/unity/plugins/put/speed "50.0"
dconf write /org/compiz/profiles/unity/plugins/put/timestep  "0.1"

# Disabling workspace-related bindings
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-left "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-right "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-left "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-right "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-up "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-down "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['']"
