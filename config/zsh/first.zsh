# Commands in this file will be executed very early in the zsh initialization
# process.


# Completion {{{
# Add path to custom completion methods
# Note: Must be defined before `compinit`
if [ -z "$OROSHI_COMPLETION_ADDED_TO_FPATH" ]; then
  fpath=(~/.oroshi/config/zsh/completion $fpath)
  OROSHI_COMPLETION_ADDED_TO_FPATH=true
fi
autoload -Uz compinit
zmodload zsh/complist
compinit
# }}}

