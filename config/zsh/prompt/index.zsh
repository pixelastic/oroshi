setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Set current path as the window title
function chpwd() {
  print -Pn "\e]2;%~/\a"
}

require 'prompt/left.zsh'

require 'prompt/right.zsh'
