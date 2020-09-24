# Left prompt
# Displays the current path, symbols about the current repository, and a colored
# prompt character

source $zshConfigDir/prompt/path.zsh
source $zshConfigDir/prompt/node.zsh
source $zshConfigDir/prompt/git.zsh
source $zshConfigDir/prompt/exit-code.zsh

function __prompt-left() {
  echo -n "$(__prompt-path)"
  echo -n "$(__prompt-node-flags)"
  echo -n "$(__prompt-git-flags)"
  echo -n "$(__prompt-exit-code)"
}

PROMPT='$(__prompt-left)'
