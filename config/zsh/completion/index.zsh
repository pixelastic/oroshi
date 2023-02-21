# Load the config
source $ZSH_CONFIG_PATH/completion/misc.zsh
source $ZSH_CONFIG_PATH/completion/styling.zsh
source $ZSH_CONFIG_PATH/completion/compdef.zsh

# Autoload the completion system
autoload -Uz compinit
# If the completion cache file is older than 20 hours, we regenerate it
# Source: https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
for dump in ~/.zcompdump(N.mh+20); do
  compinit
done
# And we load the completion from cache
compinit -C
