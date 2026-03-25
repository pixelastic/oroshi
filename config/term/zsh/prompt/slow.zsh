# Slow command warning
# Plays a sound when a command takes too long to run

# Global state variable
oroshiSlowCommandStartTime=0

# Preexec: Before command is executed
function oroshiSlowCommandPreexec() {
  # Commands that should not trigger slow command notification
  # These are typically interactive tools or commands that open editors
  local allowList=(vim nvim nano man less ssh tmux claude top htop "git commit")
  local expandedCommand="$2"

  # Return early if command matches one of the allowed patterns
  if command-in-list "$expandedCommand" -- "${allowList[@]}"; then
    oroshiSlowCommandStartTime=-1
    return
  fi

  oroshiSlowCommandStartTime=$SECONDS
}
add-zsh-hook preexec oroshiSlowCommandPreexec

# Precmd: After command is executed
function oroshiSlowCommandPrecmd() {
  local exitStatus="$?"
  local threshold=300 # in seconds

  # Stop if command was blocked
  [[ $oroshiSlowCommandStartTime -eq -1 ]] && return

  local commandDuration=$((SECONDS - oroshiSlowCommandStartTime))

  # Stop if not long enough
  [[ $commandDuration -lt $threshold ]] && return

  # Play different sound based on success/failure
  if [[ $exitStatus -eq 0 ]]; then
    audio-play-oroshi slow-success.mp3
  else
    audio-play-oroshi slow-failure.mp3
  fi
}
add-zsh-hook precmd oroshiSlowCommandPrecmd
