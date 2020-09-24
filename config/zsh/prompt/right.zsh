# Right prompt

# source $zshConfigDir/prompt/ruby.zsh
source $zshConfigDir/prompt/node.zsh
source $zshConfigDir/prompt/git.zsh
function __prompt-right() {
  # echo -n "$(__prompt-ruby-version)"
  echo -n "$(__prompt-node-version)"
  echo -n "$(__prompt-git-right)"
}


# The right prompt is reserved for information that cannot be obtained quickly
# (requiring multiple calls, or long ones). Here, we will fill this right prompt
# asynchronously.
#
# How does this work?
#
# First, we start by defining an empty RPROMPT.
#
# Then, we define the precmd function, that will be called right before
# displaying the prompt. In here, we'll simply fork a subprocess that will
# aggregate the date we need for the prompt, and write it to a file on disk.
# Then, we will send a USR1 signal.
#
# Finally, we will listen to the USR1 signal and whenever we receive one, we
# will read the file on disk, and put it in the RPROMPT.
#
# Source: http://www.anishathalye.com/2015/02/07/an-asynchronous-shell-prompt/
RPROMPT=''

# precmd
# This is called right before any prompt is displayed
# We will asynchronously write the information to disk
PROMPT_ASYNC_PID=0
function precmd() {
  # We keep a reference to the last command exit code because we're about to
  # overwrite it, and we'll need it for displaying the exit-code character in
  # the correct color
  OROSHI_LAST_COMMAND_EXIT="$?"

  # Kill the previous async process if it was already running
  if [[ "${PROMPT_ASYNC_PID}" != 0 ]]; then
    kill -s HUP $PROMPT_ASYNC_PID >/dev/null 2>&1 || :
  fi

  # Write RPROMPT to a tmp file
  # Signal parent process that we're done (will trigger TRAPUSR1)
  function async() {
    echo "$(__prompt-right)" >! "/tmp/zsh_rprompt"
    kill -s USR1 $$
  }

  # Fork subprocess, but keep a reference to its PID
  async &!
  PROMPT_ASYNC_PID=$!
}

# TRAPUSR1
# This is called whenever the USR1 signal is received
# We'll read the content of the prompt and set it
function TRAPUSR1() {
  RPROMPT="$(\cat /tmp/zsh_rprompt)"
  # Redraw
  zle && zle reset-prompt
  # Reset PID
  PROMPT_ASYNC_PID=0
}

