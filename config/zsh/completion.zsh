# Nice to have:
# [ ] Autocompletion while I type, with the first tab-suggested suggestion
# already filled in a darker color (fish-like behavior)
# [ ] Ctrl-Space to do a `ls`
# [ ] Move through suggestions using vim keys
# 
#
# Interesting readings :
# - http://grml.org/zsh/zsh-lovers.html
# - https://github.com/tomsquest/dotfiles/blob/master/zsh/bindkey.zsh
# - http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html
# - http://dustri.org/b/my-zsh-configuration.html

# Initialization
autoload -U compinit
zmodload zsh/complist
compinit

# Custom methods
fpath=(~/.oroshi/config/zsh/completion $fpath)
_git
source ./completion/npm
source ./completion/mark

# Auto escape &, ? and * when needed
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# Search for completion in the whole filename, not just on the start
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# Suggestion appears in a menu if more than one, with the first one selected
setopt MENU_COMPLETE
# When using custom chars (like ^ or ?) in a completion, zsh will interpret
# those as a regexp and fail if nothing matches.
# By unsetting the option, we let it parse them as a regexp, but continue as
# a normal string if nothing matches
# http://superuser.com/questions/584249/using-wildcards-in-commands-with-zsh
unsetopt NOMATCH
# Completion should also complete .dotfiles
setopt GLOB_DOTS

# File completion is colored
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Selected file is highlighted
zstyle ':completion:*' menu select
# Do not add trailing / to dirs or @ to symlinks
unsetopt LIST_TYPES

# Debug method to reload the completion functions {{{
r() {
  \rm -f ~/.zcompdump
  \rm -f ~/.zcompcache/grunt
  local f
  f=(~/.oroshi/config/zsh/completion/*(.))
  unfunction $f:t 2> /dev/null
  autoload -U $f:t
}
# }}}

# OPTIONS
# # Remove the annoying system beep
# setopt NO_BEEP
# # Enable spelling correction
# setopt CORRECT
# # We want the default zsh globbing features
# setopt GLOB
# # Enable zsh extended globbing features
# setopt EXTENDED_GLOB
# # Ignore case when globbing
# setopt NO_CASE_GLOB
# # Aliases get completed too (yes, the name implies the contrary, but this is
# # correct)
# setopt NO_COMPLETE_ALIASES
# # Remove trailing slash on completed paths
# setopt AUTO_REMOVE_SLASH
# # Complete start from where the cursor is in the word, not always from the end
# setopt COMPLETE_IN_WORD
# # Always move the cursor to end of line after a completion
# setopt ALWAYS_TO_END
# # # Block expanding of vars in prompt, it would add the irc/ proxy/ etc completion options
# setopt NO_CDABLE_VARS 
# # # Wait 10s for every command ending with *
# # setopt RM_STAR_WAIT
# # 
# # GENERAL
# # Enable completion caching
# zstyle ':completion:*' use-cache on
# zstyle ':completion:*' cache-path ~/.zsh/cache
# # Display completion suggestion in various groups (files, command, etc)
# zstyle ':completion:*' group-name ''
# # # Format of the group title
# zstyle ':completion:*:descriptions' format '----- %B%d%b -----'
# # Display verbose information about the completion being done
# zstyle ':completion:*' verbose yes
# # Warning message when no match found
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# # Message when displaying a hint on an command argument
# zstyle ':completion:*:messages' format '%d'
# 
# # Completion will first try to complete and if nothing is found will try to
# # spell-check instead
# zstyle ':completion:::::' completer _complete _correct







# TODO : Check the usefulness of the following options
# Background processes aren't killed on exit of shell
# setopt AUTO_CONTINUE
# The following lines were added by compinstall
# zstyle ':completion:*' completer _expand _complete _match
# zstyle ':completion:*' completions 0
# zstyle ':completion:*' format 'Completing %d'
# zstyle ':completion:*' glob 0
# zstyle ':completion:*' group-name ''
# zstyle ':completion:*' max-errors 1 numeric
# zstyle ':completion:*' substitute 0
# zstyle :compinstall filename "$HOME/.zshrc"
