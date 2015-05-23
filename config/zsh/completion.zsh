# Nice to have:
# [ ] Autocompletion while I type, with the first tab-suggested suggestion
# already filled in a darker color (fish-like behavior)
# [ ] Ctrl-Space to do a `ls`
# [ ] Move through suggestions using vim keys
# [ ] Complete host names in rsync and ssh
# 
#
# Interesting readings :
# - http://grml.org/zsh/zsh-lovers.html
# - http://bewatermyfriend.org/p/2012/003/
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

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Try to complete first, and then correct
zstyle ':completion:*' completer _complete _correct
# Search for completion in the whole filename, not just on the start
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# Disable showing the menu on first tab press
unsetopt MENU_COMPLETE
# In case of ambiguous match, complete up to the last ambiguous letter...
setopt LIST_AMBIGUOUS
# ... and then, pressing TAB will display the menu
setopt AUTO_MENU
# Try first to match regexp markers and continue as a normal char if nothing
# matches.
unsetopt NOMATCH
# Completion should also complete .dotfiles
setopt GLOB_DOTS
# Completion should not handle aliases as new commands, but internally expand
# them, and suggestion completion for the underlying command
unsetopt COMPLETE_ALIASES
# Wait 10s before rm ./*
setopt RM_STAR_WAIT

# File completion is colored
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Selected file is highlighted
zstyle ':completion:*' menu select
# Completion type separator
zstyle ':completion:*:descriptions' format '%F{069} %d%f'
# No completion found
zstyle ':completion:*:warnings' format '%F{136}  No completion found%f'
# ???
zstyle ':completion:*:messages' format '%F{171}  EDIT completion.zsh : %d%f'
# Do not add trailing / to dirs or @ to symlinks
unsetopt LIST_TYPES
# Display suggestions horizontally
setopt LIST_ROWS_FIRST



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
# # Enable spelling correction
# setopt CORRECT
# # We want the default zsh globbing features
# setopt GLOB
# # Enable zsh extended globbing features
# setopt EXTENDED_GLOB
# # Ignore case when globbing
# setopt NO_CASE_GLOB
# # Remove trailing slash on completed paths
# setopt AUTO_REMOVE_SLASH
# # Complete start from where the cursor is in the word, not always from the end
# setopt COMPLETE_IN_WORD
# # Always move the cursor to end of line after a completion
# setopt ALWAYS_TO_END
# # # Block expanding of vars in prompt, it would add the irc/ proxy/ etc completion options
# setopt NO_CDABLE_VARS 
# # 
# # GENERAL
# Display completion suggestion in various groups (files, command, etc)
# zstyle ':completion:*' group-name ''
# # Format of the group title
#
