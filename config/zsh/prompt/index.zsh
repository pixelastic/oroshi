setopt PROMPT_SUBST
autoload -U promptinit
promptinit

OROSHI_RPROMPT_GENERATION_PID=0         # pid of the script generating the RPROMPT
OROSHI_RPROMPT_PATH=/tmp/oroshi_rprompt # Where to save the output of the RPROMT

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
  oroshi-debug-timer-prompt-reset

  prompt-timer __prompt-path
  prompt-timer __prompt-node-flags
  prompt-timer __prompt-background-flags
  prompt-timer __prompt-git-flags
  prompt-timer __prompt-exit-code
}
PROMPT='$(__prompt-left)'
# }}}

# Right {{{
function __prompt-right() {
  [[ ! -r $PWD ]] && return

  __prompt-ruby-version
  __prompt-node-version
  __prompt-git-right
}
RPROMPT=''
# }}}

# precmd: Called after each command, right before the prompt is displayed {{{
function precmd() {
  # Update env GIT_ variables
  git-env-update

  # We keep a reference to the last command exit code
  OROSHI_LAST_COMMAND_EXIT="$?"

  # Kill the previous RPROMPT generation process if it was already running
  if [[ "${OROSHI_RPROMPT_GENERATION_PID}" != "0" ]]; then
    kill -s HUP $OROSHI_RPROMPT_GENERATION_PID >/dev/null 2>&1 || :
  fi

  # Write RPROMPT to a tmp file and refresh the prompt
  function async() {
    __prompt-right >! $OROSHI_RPROMPT_PATH
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
  if [[ $OROSHI_RPROMPT_GENERATION_PID != "0" ]]; then
    RPROMPT="$(\cat $OROSHI_RPROMPT_PATH)"
    OROSHI_RPROMPT_GENERATION_PID=0
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw (only if not in debug mode)
  zle && zle reset-prompt
}
# }}}
