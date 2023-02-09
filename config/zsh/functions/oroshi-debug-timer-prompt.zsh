# Execute a zsh function and saves how much time it took to run
# Used for debugging prompt performance

local OROSHI_TIMER_PROMPT_PATH=/tmp/oroshi_timer_prompt

# Add an entry to the timer
function prompt-timer() {
  local input="${(z)1}"

  # Transparently goes through if debug deactivated
  [[ $OROSHI_TIMER_PROMPT == "0" ]] && $input && return $?

  # Time before
  local before=$(/bin/date +%s%N)

  # Execute command
  ${(z)input}

  # Time difference
  local after=$(/bin/date +%s%N)
  local difference=$((($after - $before)/1000000))

  # Add to file
  echo "${difference}:${input}" >> $OROSHI_TIMER_PROMPT_PATH
}

# Reset the timer file
function oroshi-debug-timer-prompt-reset() {
  [[ $OROSHI_TIMER_PROMPT == "0" ]] && return
  echo "" > $OROSHI_TIMER_PROMPT_PATH
}

# Display the timer file
function oroshi-debug-timer-prompt() {

  local separator=":"
  local maxLimit=30
  cat $OROSHI_TIMER_PROMPT_PATH \
    | sort --reverse --numeric-sort --field-separator=${separator} \
    | head -n $maxLimit \
    | table --separator "${separator}"
}
