setopt PROMPT_SUBST
autoload -U promptinit
promptinit

OROSHI_RPROMPT_GENERATION_PID=0
OROSHI_RPROMPT_PATH=/tmp/oroshi_rprompt


# Dependencies {{{
require 'prompt/background'
require 'prompt/exit-code'
require 'prompt/git'
require 'prompt/node'
require 'prompt/path'
require 'prompt/ruby'
# }}}

# Left {{{
function __prompt-left() {
  if [[ $ZSH_PROMPT_TIMER == 1 ]]; then
    local before=$(/bin/date +%s%N)
  fi

  echo -n "$(__prompt-path)"
  echo -n "$(__prompt-node-flags)"
  echo -n "$(__prompt-background-flags)"
  echo -n "$(__prompt-git-flags)"
  echo -n "$(__prompt-exit-code)"

  if [[ $ZSH_PROMPT_TIMER == 1 ]]; then
    local after=$(/bin/date +%s%N)

    local difference=$((($after - $before)/1000000))
    echo "${difference}ms"
  fi
}
PROMPT='$(__prompt-left)'
# }}}

# Right {{{
function __prompt-right() {
  [[ ! -r $PWD ]] && return

  echo -n "$(__prompt-ruby-version)"
  echo -n "$(__prompt-node-version)"
  echo -n "$(__prompt-git-right)"
}
RPROMPT=''
# }}}

# precmd: Called after each command, right before the prompt is displayed {{{
function precmd() {
  # We keep a reference to the last command exit code
  OROSHI_LAST_COMMAND_EXIT="$?"

  # Kill the previous RPROMPT generation process if it was already running
  if [[ "${OROSHI_RPROMPT_GENERATION_PID}" != 0 ]]; then
    kill -s HUP $OROSHI_RPROMPT_GENERATION_PID >/dev/null 2>&1 || :
  fi

  # Write RPROMPT to a tmp file and refresh the prompt
  function async() {
    echo "$(__prompt-right)" >! $OROSHI_RPROMPT_PATH
    prompt-refresh
  }

  # Fork subprocess, but keep a reference to its PID
  async &!
  OROSHI_RPROMPT_GENERATION_PID=$!
}
# }}}

# TRAPUSR1: Refresh prompt on demand {{{
# Whenever we receive USR1, we refresh the prompt display
# We use it to force a refresh of the prompt
function TRAPUSR1() {
  # RPROMPT was generated in the background, we display it
  if [[ $OROSHI_RPROMPT_GENERATION_PID != 0 ]]; then
    RPROMPT="$(\cat $OROSHI_RPROMPT_PATH)"
    OROSHI_RPROMPT_GENERATION_PID=0
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw
  zle && zle reset-prompt
}
# }}}
