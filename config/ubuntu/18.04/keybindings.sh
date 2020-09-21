#!/usr/bin/env bash

# Disable the display of the Search/Preview Ubuntu screen when pressing the
# Windows key. We assign it to F14 that does not bind to anything.
gsettings set org.gnome.mutter overlay-key 'F14'     

# Custom keybindings {{{
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings '["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"]'

declare -A custom
# Termite
custom[0,name]='Kitty'
custom[0,command]='/home/tim/local/bin/kitty'
custom[0,binding]='<Super>t'
# Chrome pro
custom[1,name]='Chrome Pro'
custom[1,command]='google-chrome --profile-directory="Profile 2"'
custom[1,binding]='<Primary><Super>c'
# Chrome perso
custom[2,name]='Chrome Perso'
custom[2,command]='google-chrome --profile-directory="Profile 3"'
custom[2,binding]='<Alt><Primary><Super>c'
# Keepass
custom[3,name]='Keepass'
custom[3,command]='keepassx ~/perso/Dropbox/tim/keys.kdbx'
custom[3,binding]='<Primary><Super>k'
# Tomate
custom[4,name]='Tomate'
custom[4,command]='tomate-gtk'
custom[4,binding]='<Primary><Super>t'
# Calculator
custom[5,name]='Calculator'
custom[5,command]='gnome-calculator'
custom[5,binding]='Insert'
# Slack
custom[6,name]='Slack'
custom[6,command]='slack'
custom[6,binding]='<Super>s'
# TODO
custom[7,name]='TODO'
custom[7,command]='TODO'
custom[7,binding]=''
# TODO
custom[8,name]='TODO'
custom[8,command]='TODO'
custom[8,binding]=''
# TODO
custom[9,name]='TODO'
custom[9,command]='TODO'
custom[9,binding]=''

for ((i=0;i<=10;i++)) do
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name "'${custom[$i,name]}'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ command "'${custom[$i,command]}'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ binding "'${custom[$i,binding]}'"
done
# }}}


# The headers mimic what can be found in the Keyboard binding UI screen

# Run the following commands to access all keys:
# - gsettings list-recursively org.gnome.desktop.wm.keybindings
# - gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys
# - gsettings list-recursively org.gnome.mutter.keybindings


# Search
gsettings set org.gnome.settings-daemon.plugins.media-keys search 'twosuperior'
# Hide all normal windows
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
# Switch applications
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"

# Copy a screenshot of an area to clipboard
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip '<Super>Print'
# Save a screenshot of an area to Pictures
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot '<Primary><Super>Print'
# Save screenshot to Pictures
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot 'Print'

# Lock screen
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver '<Primary><Super>l'

# Close window
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"
# Restore Window
gsettings set org.gnome.desktop.wm.keybindings unmaximize '["<Alt><Super>Down"]'
# Toggle Maximization State
gsettings set org.gnome.desktop.wm.keybindings maximize '["<Alt><Super>Up"]'
# View split on left
gsettings set org.gnome.mutter.keybindings toggle-tiled-left '["<Alt><Super>Left"]'
# View split on right
gsettings set org.gnome.mutter.keybindings toggle-tiled-right '["<Alt><Super>Right"]'





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
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-on-all-workspaces '@as []'
gsettings set org.gnome.desktop.wm.keybindings toggle-shaded '@as []'

gsettings set org.gnome.settings-daemon.plugins.media-keys logout ''
gsettings set org.gnome.settings-daemon.plugins.media-keys screenreader ''
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-mute 'XF86AudioMute'
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up 'XF86AudioRaiseVolume'
gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot ''
gsettings set org.gnome.settings-daemon.plugins.media-keys previous ''
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center ''
gsettings set org.gnome.settings-daemon.plugins.media-keys stop ''
gsettings set org.gnome.settings-daemon.plugins.media-keys home ''
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal ''
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot-clip ''
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier ''
gsettings set org.gnome.settings-daemon.plugins.media-keys help ''
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-in ''
gsettings set org.gnome.settings-daemon.plugins.media-keys calculator ''
gsettings set org.gnome.settings-daemon.plugins.media-keys video-out '<Super>p'
gsettings set org.gnome.settings-daemon.plugins.media-keys eject ''
gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot-clip ''
gsettings set org.gnome.settings-daemon.plugins.media-keys media ''
gsettings set org.gnome.settings-daemon.plugins.media-keys www ''
gsettings set org.gnome.settings-daemon.plugins.media-keys play ''
gsettings set org.gnome.settings-daemon.plugins.media-keys email ''
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down 'XF86AudioLowerVolume'
gsettings set org.gnome.settings-daemon.plugins.media-keys decrease-text-size ''
gsettings set org.gnome.settings-daemon.plugins.media-keys on-screen-keyboard ''
gsettings set org.gnome.settings-daemon.plugins.media-keys next ''
gsettings set org.gnome.settings-daemon.plugins.media-keys increase-text-size ''
gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 'uint32 30'
gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-out ''
gsettings set org.gnome.settings-daemon.plugins.media-keys priority 0
gsettings set org.gnome.settings-daemon.plugins.media-keys screencast ''
gsettings set org.gnome.settings-daemon.plugins.media-keys toggle-contrast ''
gsettings set org.gnome.settings-daemon.plugins.media-keys pause ''
gsettings set org.gnome.settings-daemon.plugins.media-keys active true

gsettings set org.gnome.mutter.keybindings switch-monitor '["<Super>p", "XF86Display"]'
gsettings set org.gnome.mutter.keybindings tab-popup-cancel '@as []'
gsettings set org.gnome.mutter.keybindings rotate-monitor '["XF86RotateWindows"]'
gsettings set org.gnome.mutter.keybindings tab-popup-select '@as []'

