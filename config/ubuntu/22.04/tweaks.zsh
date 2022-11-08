#!/usr/bin/env zsh

# Run `dconf-watch` to see in real time which settings are changed when you
# tinker in the settings UI
#
# Note: If keybindings or config does not work, don't forget to click on the
# gear icon when logging in and picking X11 and not Wayland.

# Disable animations
dconf write "/org/gnome/desktop/interface/enable-animations" false

# Remove delay before repeating keys
dconf write "/org/gnome/desktop/peripherals/keyboard/delay" "uint32 150"
