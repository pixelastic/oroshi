# Slow command warning
# Plays a sound when a command takes too long to run

# Global state variable
oroshiSlowCommandStartTime=0

# Preexec: Before command is executed
function oroshiSlowCommandPreexec() {
  local blockList=(vim nvim nano man less ssh tmux claude top htop)
  local expandedCommand="$2"
  local firstWord="${expandedCommand[(w)1]}"

  # Return early if command is blocked
  if (( ${blockList[(Ie)$firstWord]} )); then
    oroshiSlowCommandStartTime=-1
    return
  fi

  oroshiSlowCommandStartTime=$SECONDS
}
add-zsh-hook preexec oroshiSlowCommandPreexec

# Precmd: After command is executed
function oroshiSlowCommandPrecmd() {
  local threshold=300 # in seconds

  # Stop if command was blocked
  [[ $oroshiSlowCommandStartTime -eq -1 ]] && return

  local commandDuration=$((SECONDS - oroshiSlowCommandStartTime))

  # Stop if not long enough
  [[ $commandDuration -lt $threshold ]] && return

  audio-play-oroshi slow.mp3
}
add-zsh-hook precmd oroshiSlowCommandPrecmd
