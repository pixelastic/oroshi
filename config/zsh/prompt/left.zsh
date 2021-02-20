# Left prompt
# Displays the current path, symbols about the current repository, and a colored
# prompt character

require 'prompt/path.zsh'
require 'prompt/node.zsh'
require 'prompt/git.zsh'
require 'prompt/background.zsh'
require 'prompt/exit-code.zsh'

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
