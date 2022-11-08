#!/usr/bin/env zsh

# Run `dconf-watch` to see in real time which settings are changed when you
# tinker in the settings UI

# Disable animations
dconf write "/org/gnome/desktop/interface/enable-animations" false
