#!/usr/bin/env zsh
typeset -A customKeys
local customKeys=(
  toggle-tiled-left '<Alt><Super>Left'
  toggle-tiled-right '<Alt><Super>Right'
)
for configName configValue in ${(kv)customKeys}; do
  gsettings set org.gnome.mutter.keybindings $configName "['$configValue']"
done



