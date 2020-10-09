#!/usr/bin/env zsh
typeset -A customKeys
local customKeys=(
  search 'twosuperior'
)
for configName configValue in ${(kv)customKeys}; do
  gsettings set org.gnome.settings-daemon.plugins.media-keys $configName "['$configValue']"
done
