#!/usr/bin/env zsh
local GSETTINGS_ROOT="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
local GSETTINGS_DIRECTORY="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

local                  shortcuts=(
# Name                 Command                                               Binding
"Calculator"           "gnome-calculator"                                    "Insert"
"Chrome"               "google-chrome"                                       "<Super>C"
"Flameshot"            "/usr/bin/flameshot gui"                              "<Super>Print"
"Keepass"              "keepassx ~/perso/Dropbox/tim/keys.kdbx"              "<Super>K"
"Kitty"                "/usr/bin/kitty"                                      "<Super>T"
"Peek"                 "/home/tim/.oroshi/scripts/bin/peek"                  "<Super><Alt>Print"
"Pomodoro Start/Pause" "/home/tim/.oroshi/scripts/bin/pomodoro-toggle-pause" "<Super><Alt>I"
"Pomodoro Start/Stop"  "/home/tim/.oroshi/scripts/bin/pomodoro-toggle-stop"  "<Super><Alt>O"
"Slack"                "/usr/bin/slack"                                      "<Super>S"
"Music Start/Pause"    "/home/tim/.oroshi/scripts/bin/music-toggle-pause"    "<Super>I"
"Music Next"           "/home/tim/.oroshi/scripts/bin/music-next"            "<Super>L"
"Music Previous"       "/home/tim/.oroshi/scripts/bin/music-next"            "<Super>H"
)


# Iterating through all the bindings
local shortcut_count=$((${#shortcuts[@]} / 3))
local shortcut_inventory=()
for shortcut_index in {1..$shortcut_count}; do
  local array_index=$((1 + ($shortcut_index - 1) * 3))

  local shortcut_name=$shortcuts[$array_index]
  local shortcut_command=$shortcuts[$array_index+1]
  local shortcut_binding=$shortcuts[$array_index+2]

  # Setting each shortcut individually
  gsettings set ${GSETTINGS_ROOT}:${GSETTINGS_DIRECTORY}/custom${shortcut_index}/ name    "'${shortcut_name}'"
  gsettings set ${GSETTINGS_ROOT}:${GSETTINGS_DIRECTORY}/custom${shortcut_index}/ command "'${shortcut_command}'"
  gsettings set ${GSETTINGS_ROOT}:${GSETTINGS_DIRECTORY}/custom${shortcut_index}/ binding "'${shortcut_binding}'"

  echo "$shortcut_index/ $shortcut_name: [$shortcut_binding] => $shortcut_command"

  shortcut_inventory+="\"${GSETTINGS_DIRECTORY}/custom${shortcut_index}/\""
done

gsettings set \
  org.gnome.settings-daemon.plugins.media-keys \
  custom-keybindings \
  "[${(j:,:)shortcut_inventory}]"


