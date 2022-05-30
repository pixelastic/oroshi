#!/usr/bin/env zsh
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings '["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/", "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"]'

# Sometimes it seems impossible to remap a shortcut to a specific key, maybe
# because the OS is already remapping it a higher level
# Run the custom script `kbl '<Super>t'` for example to see what is using
# this mapping, or unmap all instances with `kbR '<Super>t'`

declare -A custom
# Terminal
custom[0,name]='Kitty'
custom[0,command]='/usr/bin/kitty'
custom[0,binding]='<Super>T'
# Chrome
custom[1,name]='Chrome'
custom[1,command]='google-chrome'
custom[1,binding]='<Super>C'
# Keepass
custom[3,name]='Keepass'
custom[3,command]='keepassx ~/perso/Dropbox/tim/keys.kdbx'
custom[3,binding]='<Super>K'
# TODO
custom[4,name]=''
custom[4,command]=''
custom[4,binding]=''
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
# Peek
custom[8,name]='Peek'
custom[8,command]='/home/tim/.oroshi/scripts/bin/peek'
custom[8,binding]='<Super><Alt>Print'
# Pomodoro Start/Pause
custom[9,name]='Pomodoro Start/Pause'
custom[9,command]='/home/tim/.oroshi/scripts/bin/pomodoro-toggle-pause'
custom[9,binding]='<Super><Alt>I'
# Pomodoro Start/Stop
custom[10,name]='Pomodoro Start/Stop'
custom[10,command]='/home/tim/.oroshi/scripts/bin/pomodoro-toggle-stop'
custom[10,binding]='<Super><Alt>O'

for ((i=0;i<=11;i++)) do
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name "'${custom[$i,name]}'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ command "'${custom[$i,command]}'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ binding "'${custom[$i,binding]}'"
done
