declare -A OROSHI_REQUIRED_FILES
OROSHI_REQUIRED_FILES=()

# Source a config file, and make sure it is only loaded once
# Usage:
# $ require 'tools/nvm'        # Loads the tools/nvm.zsh file in oroshi
# $ require ~/.oroshi/config/zsh/tools/nvm'        # Loads the tools/nvm.zsh file in oroshi
function require {
  # Start debug timer
  local before=$(/bin/date +%s%N)

  local basePath=~/.oroshi/config/zsh/
  basePath="${~basePath}"

  local requirePath="$1"
  requirePath=${~requirePath}
  # Add basePath prefix and .zsh suffix if short form is given
  [[ $requirePath != /* ]] && requirePath="${basePath}${requirePath}"
  [[ $requirePath != *.zsh ]] && requirePath="${requirePath}.zsh"


  # Stop if already loaded
  [[ $OROSHI_REQUIRED_FILES[$requirePath] == '1' ]] && return

  # Mark this file as loaded
  OROSHI_REQUIRED_FILES[$requirePath]='1'

  source ${requirePath}

  # Store debug timer
  local after=$(/bin/date +%s%N)

  local difference=$((($after - $before)/1000000))
  OROSHI_TIMER_REQUIRE_STACK+="${difference}:${requirePath}\n"
}
