# Source a file, but also display loading time when debug is enabled
function require {
  local requirePath="$1"

  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local before=$(/bin/date +%s%N)
  fi

  source ~/.oroshi/config/zsh/${requirePath}

  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local after=$(/bin/date +%s%N)

    local difference=$((($after - $before)/1000000))
    OROSHI_SOURCE_TIMER_STACK+="${difference}:${requirePath}\n"
  fi
}
