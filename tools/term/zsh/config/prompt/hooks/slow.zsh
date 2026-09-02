# Slow command warning
# Plays a sound when a command takes too long to run

# Global state variable
oroshi_slow_command_start_time=0

# Preexec: Before command is executed
function oroshi-slow-command-preexec() {
  # Commands that should not trigger slow command notification
  # These are typically interactive tools or commands that open editors
  local allowList=(
    claude
    git-commit-create
    git-commit-create-all
    git-commit-create-all-auto
    git-commit-list
    git-file-diff
    git-file-edit
    git-file-watch
    gws
    htop
    less
    man
    nano
    nvim
    ralph
    review
    ssh
    tmux
    top
    typora
    vim
    yrs
    "git commit"
    "yarn-run serve"
    "yarn-run writing-buddy"
    "yr serve"
  )
  local expandedCommand="$2"

  # Store the expanded command in an environment variable for inspection
  export OROSHI_LAST_COMMAND="$expandedCommand"

  # Return early if command matches one of the allowed patterns
  if solkan --allow-list "${(j:,:)allowList}" "$expandedCommand" &>/dev/null; then
    oroshi_slow_command_start_time=-1
    return
  fi

  oroshi_slow_command_start_time=$SECONDS
}

# Precmd: After command is executed
function oroshi-slow-command-precmd() {
  local exitStatus="$?"
  local startTime=$oroshi_slow_command_start_time
  local commandDuration=$((SECONDS - startTime))
  local threshold=300 # in seconds

  # Reset start time
  oroshi_slow_command_start_time=0

  # Stop if allowed command
  [[ $startTime -eq -1 ]] && return
  # Stop if killed by CTRL-C (exit code 130)
  [[ $exitStatus -eq 130 ]] && return
  # Stop if not long enough
  [[ $commandDuration -lt $threshold ]] && return

  # Notify with different sound based on success/failure
  if [[ $exitStatus -eq 0 ]]; then
    kitty-notify --sound slow-success.mp3
    return
  fi
  kitty-notify --sound slow-failure.mp3
}
