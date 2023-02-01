declare -A OROSHI_SOURCED_FILES
OROSHI_SOURCED_FILES=()

# Source a config file, and make sure it is only loaded once
# Usage:
# $ require 'tools/nvm'        # Loads the tools/nvm.zsh file in oroshi
function require {
  local requirePath="$1"

  # Start debug timer
  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local before=$(/bin/date +%s%N)
  fi

  # Stop if already loaded
  [[ $OROSHI_SOURCED_FILES[$requirePath] == '1' ]] && return

  source ~/.oroshi/config/zsh/${requirePath}.zsh

  # Mark this file as loaded
  OROSHI_SOURCED_FILES[$requirePath]='1'

  # Store debug timer
  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local after=$(/bin/date +%s%N)

    local difference=$((($after - $before)/1000000))
    OROSHI_SOURCE_TIMER_STACK+="${difference}:${requirePath}\n"
  fi
}
