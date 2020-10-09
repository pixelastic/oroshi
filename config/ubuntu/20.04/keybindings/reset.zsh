#!/usr/bin/env zsh
# mutter {{{
typeset -a mutter
local mutter=(
  rotate-monitor 
  switch-monitor 
  tab-popup-cancel 
  tab-popup-select 
  toggle-tiled-left 
  toggle-tiled-right 
)
for configName in $mutter; do
  gsettings set org.gnome.mutter.keybindings $configName '@as []'
done
# }}}

# wm {{{
typeset -a wm
local wm=(
  activate-window-menu 
  always-on-top 
  begin-move 
  begin-resize 
  close
  cycle-group 
  cycle-group-backward 
  cycle-panels 
  cycle-panels-backward 
  cycle-windows 
  cycle-windows-backward 
  lower 
  maximize
  maximize-horizontally 
  maximize-vertically 
  minimize 
  move-to-center 
  move-to-corner-ne 
  move-to-corner-nw 
  move-to-corner-se 
  move-to-corner-sw 
  move-to-monitor-down 
  move-to-monitor-left 
  move-to-monitor-right 
  move-to-monitor-up 
  move-to-side-e 
  move-to-side-n 
  move-to-side-s 
  move-to-side-w 
  move-to-workspace-1 
  move-to-workspace-2 
  move-to-workspace-3 
  move-to-workspace-4 
  move-to-workspace-5 
  move-to-workspace-6 
  move-to-workspace-7 
  move-to-workspace-8 
  move-to-workspace-9 
  move-to-workspace-10 
  move-to-workspace-11 
  move-to-workspace-12 
  move-to-workspace-down 
  move-to-workspace-last 
  move-to-workspace-left 
  move-to-workspace-right 
  move-to-workspace-up 
  panel-main-menu 
  panel-run-dialog 
  raise 
  raise-or-lower 
  set-spew-mark 
  show-desktop
  switch-applications
  switch-applications-backward 
  switch-group 
  switch-group-backward 
  switch-input-source 
  switch-input-source-backward 
  switch-panels 
  switch-panels-backward 
  switch-to-workspace-1 
  switch-to-workspace-2 
  switch-to-workspace-3 
  switch-to-workspace-4 
  switch-to-workspace-5 
  switch-to-workspace-6 
  switch-to-workspace-7 
  switch-to-workspace-8 
  switch-to-workspace-9 
  switch-to-workspace-10 
  switch-to-workspace-11 
  switch-to-workspace-12 
  switch-to-workspace-down 
  switch-to-workspace-last 
  switch-to-workspace-left 
  switch-to-workspace-right 
  switch-to-workspace-up 
  switch-windows 
  switch-windows-backward 
  toggle-above 
  toggle-fullscreen 
  toggle-maximized 
  toggle-on-all-workspaces 
  toggle-shaded 
  unmaximize
)
# }}}

for configName in $wm; do
  gsettings set org.gnome.desktop.wm.keybindings $configName '@as []'
done

