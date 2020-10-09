#!/usr/bin/env zsh
typeset -A customKeys
local customKeys=(
  close '<Alt>F4'
  maximize '<Alt><Super>Up'
  show-desktop '<Super>d'
  switch-applications '<Alt>Tab'
  unmaximize '<Alt><Super>Down'
)
for configName configValue in ${(kv)customKeys}; do
  gsettings set org.gnome.desktop.wm.keybindings $configName "['$configValue']"
done
