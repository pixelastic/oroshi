#!/usr/bin/env zsh

# Showing the preview with ^2 instead of just windows
gsettings set org.gnome.mutter overlay-key 'F14'     

# Custom keybindings
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized '["<Alt><Super>Home"]'
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"

# Disable other keybindings
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu '@as []'
gsettings set org.gnome.desktop.wm.keybindings always-on-top '@as []'
gsettings set org.gnome.desktop.wm.keybindings begin-move '@as []'
gsettings set org.gnome.desktop.wm.keybindings begin-resize '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-group '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-group-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-panels '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-panels-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-windows '@as []'
gsettings set org.gnome.desktop.wm.keybindings cycle-windows-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings lower '@as []'
gsettings set org.gnome.desktop.wm.keybindings maximize "[]"
gsettings set org.gnome.desktop.wm.keybindings maximize-horizontally '@as []'
gsettings set org.gnome.desktop.wm.keybindings maximize-vertically '@as []'
gsettings set org.gnome.desktop.wm.keybindings minimize '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-center '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-ne '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-nw '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-se '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-sw '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-side-e '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-side-n '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-side-s '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-side-w '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-9 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-11 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-12 '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last '@as []'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left '[]'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right '[]'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up '@as []'
gsettings set org.gnome.desktop.wm.keybindings panel-main-menu '@as []'
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog '@as []'
gsettings set org.gnome.desktop.wm.keybindings raise '@as []'
gsettings set org.gnome.desktop.wm.keybindings raise-or-lower '@as []'
gsettings set org.gnome.desktop.wm.keybindings set-spew-mark '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-group '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-input-source '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-panels '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-panels-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-9 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-11 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-12 '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-windows '@as []'
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-above '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-on-all-workspaces '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-shaded '@as []'
gsettings set org.gnome.desktop.wm.keybindings unmaximize "[]"