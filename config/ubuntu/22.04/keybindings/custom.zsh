#!/usr/bin/env zsh
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings '["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"]'

# Sometimes it seems impossible to remap a shortcut to a specific key, maybe
# because the OS is already remapping it a higher level
# Run the custom script `kbl '<Super>t'` for example to see what is using
# this mapping, or unmap all instances with `kbR '<Super>t'`

declare -A custom
# Terminal
custom[0,name]='Kitty'
custom[0,command]='/usr/bin/kitty'
custom[0,binding]='<Super>t'
# Chrome
custom[1,name]='Chrome'
custom[1,command]='google-chrome'
custom[1,binding]='<Primary><Super>c'
# Keepass
custom[3,name]='Keepass'
custom[3,command]='keepassx ~/perso/Dropbox/tim/keys.kdbx'
custom[3,binding]='<Primary><Super>k'
# Tomate
custom[4,name]='Pomodoro'
custom[4,command]='gnome-pomodoro'
custom[4,binding]='<Primary><Super>t'
# Calculator
custom[5,name]='Calculator'
custom[5,command]='gnome-calculator'
custom[5,binding]='Insert'
# Slack
custom[6,name]='Slack'
custom[6,command]='/usr/bin/slack'
custom[6,binding]='<Super>S'
# Flameshot
custom[7,name]='Flameshot'
custom[7,command]='/usr/bin/flameshot gui'
custom[7,binding]='<Super>Print'
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
