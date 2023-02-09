setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# When the prompt gets displayed for the first time, both left and right prompt
# display a fast version, so we can use the prompt quickly.
#
# Then, on each new command:
# - Left prompt will display its fast version, then update to the enhanced one
# - Right prompt will keep previous display, then update it
OROSHI_PROMPT_ENHANCED_MODE=0 
OROSHI_PROMPT_GENERATION_PID=0
OROSHI_PROMPT_RIGHT_PATH=/tmp/oroshi_prompt_right
OROSHI_PROMPT_LEFT_PATH=/tmp/oroshi_prompt_left

# Dependencies {{{
require 'prompt/background'
require 'prompt/exit-code'
require 'prompt/git'
require 'prompt/node'
require 'prompt/path'
require 'prompt/ruby'
# }}}


# Left {{{
# The left prompt displays information quickly. Heavy computation is done in the
# background and the prompt is updated afterwards.
function __prompt-left() {
  __prompt-path
  __prompt-node-flags
  __prompt-background-flags
  __prompt-git-flags
  __prompt-git-status
  __prompt-exit-code
}
function __prompt-left-enhanced() {
  OROSHI_PROMPT_ENHANCED_MODE=1
  __prompt-left
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
function __prompt-right-enhanced() {
  OROSHI_PROMPT_ENHANCED_MODE=1
  __prompt-right
}
RPROMPT='$(__prompt-right)'
# }}}

# precmd: Called after each command, right before the prompt is displayed {{{
function precmd() {
  # Update env GIT_ variables
  git-env-update

  # We keep a reference to the last command exit code
  OROSHI_LAST_COMMAND_EXIT="$?"

  # Kill the previous prompt generation process if it was already running
  if [[ "${OROSHI_PROMPT_GENERATION_PID}" != "0" ]]; then
    kill -s HUP $OROSHI_PROMPT_GENERATION_PID >/dev/null 2>&1 || :
  fi

  # Write left and right prompts to a tmp file and refresh the prompt
  function async() {
    __prompt-left-enhanced >! $OROSHI_PROMPT_LEFT_PATH
    __prompt-right-enhanced >! $OROSHI_PROMPT_RIGHT_PATH
    prompt-refresh
  }

  # Fork subprocess, but keep a reference to its PID
  async &!
  OROSHI_PROMPT_GENERATION_PID=$!
}
# }}}

# TRAPUSR1: Refresh prompt on demand {{{
# Whenever we receive USR1, we refresh the prompt display
# We use it to force a refresh of the prompt
function TRAPUSR1() {
  # Prompt was generated in the background, we update it
  if [[ $OROSHI_PROMPT_GENERATION_PID != "0" ]]; then
    PROMPT="$(<$OROSHI_PROMPT_LEFT_PATH)"
    RPROMPT="$(<$OROSHI_PROMPT_RIGHT_PATH)"
    OROSHI_PROMPT_GENERATION_PID=0
    OROSHI_PROMPT_ENHANCED_MODE=0
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw
  zle && zle reset-prompt

  # Reset prompt to fast display for next one
  PROMPT='$(__prompt-left)'
}
# }}}
