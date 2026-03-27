# Slow command warning
# Plays a sound when a command takes too long to run

# Global state variable
oroshiSlowCommandStartTime=0

# Preexec: Before command is executed
function oroshiSlowCommandPreexec() {
  # Commands that should not trigger slow command notification
  # These are typically interactive tools or commands that open editors
  local allowList=(
    claude
    git-commit-create
    git-commit-create-staged
    git-commit-list
    git-file-diff
    gws
    htop
    less
    man
    nano
    nvim
    ssh
    tmux
    top
    vim
    "git commit"
  )
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
  local startTime=$oroshiSlowCommandStartTime
  local commandDuration=$((SECONDS - startTime))
  local threshold=300 # in seconds

  # Reset start time
  oroshiSlowCommandStartTime=0

  # Stop if allowed command
  [[ $startTime -eq -1 ]] && return
  # Stop if killed by CTRL-C (exit code 130)
  [[ $exitStatus -eq 130 ]] && return
  # Stop if not long enough
  [[ $commandDuration -lt $threshold ]] && return

  # Play different sound based on success/failure
  if [[ $exitStatus -eq 0 ]]; then
    audio-play-oroshi slow-success.mp3
    return
  fi
  audio-play-oroshi slow-failure.mp3
}
add-zsh-hook precmd oroshiSlowCommandPrecmd
