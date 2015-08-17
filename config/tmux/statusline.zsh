#!/usr/bin/env zsh

local output=''

# Clock
local clock="$(date +'%a %d/%m %H:%M')"
output="  $clock $output"

# Current ip
local ip=''
if is-online; then
  ip="  $(my-ip)"
else
  ip='#[fg=colour160,bold]  offline!#[default]'
fi
output="$ip $output"

# Battery life
# Do not display if full
# Display in green if charging
# Display in grey, yellow and red when level drops
local battery_status="$(battery-status)"
local battery_percent="$(battery-percent)"
if [[ $battery_percent -ne 100 ]]; then
  # Charging, green
  if [[ $battery_status == 'charging' ]]; then
     output="#[fg=colour35] $battery_percent%#[default] $output"
  else
    if [[ $battery_percent -lt 100 && $battery_percent -ge 50 ]]; then
      output=" $battery_percent% $output"
    fi
    if [[ $battery_percent -lt 50 && $battery_percent -ge 10 ]]; then
      output="#[fg=colour136] $battery_percent%#[default] $output"
    fi
    if [[ $battery_percent -lt 10 ]]; then
      output="#[fg=colour160,bold] $battery_percent%#[default] $output"
    fi
  fi
fi


#  3 Pending mentions on Twitter ?
#  2 Pending emails ? 
# curl -u timcc.perso --silent "https://mail.google.com/mail/feed/atom"
# need to parse the resulting xml, and putting a password specific for
# a specific app
#  3pm-7pm Support slot

echo $output
