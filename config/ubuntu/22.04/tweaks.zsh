#!/usr/bin/env zsh

# Run `dconf-watch` to see in real time which settings are changed when you
# tinker in the settings UI
#
# Note: If keybindings or config does not work, don't forget to click on the
# gear icon when logging in and picking X11 and not Wayland.

# Disable animations
dconf write "/org/gnome/desktop/interface/enable-animations" false

# Remove delay before repeating keys
dconf write "/org/gnome/desktop/peripherals/keyboard/delay" "uint32 300"

# Use darkmode
dconf write "/org/gnome/desktop/interface/gtk-theme" "'Yaru-dark'"
dconf write "/org/gnome/desktop/interface/color-scheme" "'prefer-dark'"
dconf write "/org/gnome/gedit/preferences/editor/scheme" "'Yaru-dark'"

# Enable night mode all day long
dconf write "/org/gnome/settings-daemon/plugins/color/night-light-enabled" true
dconf write "/org/gnome/settings-daemon/plugins/color/night-light-schedule-automatic" false
dconf write "/org/gnome/settings-daemon/plugins/color/night-light-temperature" "uint32 4200"
dconf write "/org/gnome/settings-daemon/plugins/color/night-light-schedule-from" 4.0
dconf write "/org/gnome/settings-daemon/plugins/color/night-light-schedule-to" 3.5

# Disable Dock
dconf write "/org/gnome/shell/extensions/dash-to-dock/dock-fixed" false
dconf write "/org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size" 16
dconf write "/org/gnome/shell/extensions/dash-to-dock/show-mounts-network" false

# Enable Do Not Disturb
dconf write "/org/gnome/desktop/notifications/show-banners" false

# Natural scrolling for touchpad
dconf write "/org/gnome/desktop/peripherals/touchpad/natural-scroll" false
dconf write "/org/gnome/desktop/peripherals/touchpad/speed" 0.75
