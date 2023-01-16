setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Set current path as the window title
function chpwd() {
  print -Pn "\e]2;%~/\a"
}

# This is called whenever the USR1 signal is received
# We use it to force a refresh of the prompt
function TRAPUSR1() {
  # If was generating the right prompt, we update it
  if [[ $PROMPT_ASYNC_PID != 0 ]]; then
    RPROMPT="$(\cat /tmp/zsh_rprompt)"
    # Reset PID
    PROMPT_ASYNC_PID=0
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw
  zle && zle reset-prompt
}

require 'prompt/left.zsh'

require 'prompt/right.zsh'
