# Load the config
require 'completion/misc'
require 'completion/styling'
require 'completion/compdef'

# Init the completion system
autoload -U compinit;
compinit

function reload-completion() {
  \rm -f ~/.zcompdump 2>/dev/null
  for item in ~/.oroshi/config/zsh/completion/compdef/*; do
    unfunction ${item:t}
    autoload -U ${item:t}
  done
}
