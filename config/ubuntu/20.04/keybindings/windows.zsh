#!/usr/bin/env zsh

dconf write /org/gnome/desktop/wm/keybindings/maximize "['<Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['<Super>Down']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-left "['<Super>Left']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-right "['<Super>Right']"
dconf write /org/gnome/desktop/wm/keybindings/close "['<Alt>F4','<Super>q']"
