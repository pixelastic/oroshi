#!/usr/bin/env zsh

source ~/.oroshi/config/ubuntu/20.04/keybindings/reset.zsh
source ~/.oroshi/config/ubuntu/20.04/keybindings/system.zsh
source ~/.oroshi/config/ubuntu/20.04/keybindings/screenshots.zsh
# Below files uses gsettings. Might be easier to use dconf as we can watch for
# changes with dconf watch /
source ~/.oroshi/config/ubuntu/20.04/keybindings/window-manager.zsh
source ~/.oroshi/config/ubuntu/20.04/keybindings/mutter.zsh
source ~/.oroshi/config/ubuntu/20.04/keybindings/media-keys.zsh
source ~/.oroshi/config/ubuntu/20.04/keybindings/custom.zsh




# # Copy a screenshot of an area to clipboard
# gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip '<Super>Print'
# # Save a screenshot of an area to Pictures
# gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot '<Primary><Super>Print'
# # Save screenshot to Pictures
# gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot 'Print'

