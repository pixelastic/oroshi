# TODO : Take great info from http://grml.org/zsh/zsh-lovers.html
# TODO : cd should not list hidden dirs
# TODO : cding should word with parts of the dir name
# TODO : mkdiring inside an existing directory should accept tab completion
#        eg. mkdir ~/Document/Photos/christ<TAB> -> 2012-02-05 - Christchurch

# Use custom completion functions
fpath=(~/.oroshi/config/zsh/completion $fpath)

# Lazy init completion
autoload -U compinit
compinit

# Debug method to reload the completion functions
r() {
	local f
	f=(~/.oroshi/config/zsh/completion/*(.))
	unfunction $f:t 2> /dev/null
	autoload -U $f:t
}

# OPTIONS
# Remove the annoying system beep
setopt NO_BEEP
# Enable spelling correction
setopt CORRECT
# We want the default zsh globbing features
setopt GLOB
# Enable zsh extended globbing features
setopt EXTENDED_GLOB
# If the globbing does not match anything, the glob pattern is passed as-is.
# This is needed for git and the HEAD^ syntax where ^ means a symbolic link in
# zsh globbing.
setopt NO_NOMATCH
# Ignore case when globbing
setopt NO_CASE_GLOB
# Include dotfiles in globbing
setopt GLOB_DOTS
# Aliases get completed too (yes, the name implies the contrary, but this is
# correct)
setopt NO_COMPLETE_ALIASES
# Do not autofill the completion with the first match
setopt NO_MENU_COMPLETE
# Remove trailing slash on completed paths
setopt AUTO_REMOVE_SLASH
# Complete start from where the cursor is in the word, not always from the end
setopt COMPLETE_IN_WORD
# Always move the cursor to end of line after a completion
setopt ALWAYS_TO_END
# Allow moving to a directory without typing cd
setopt AUTO_CD
# Block expanding of vars in prompt, it would add the irc/ proxy/ etc completion options
setopt NO_CDABLE_VARS	
# Do not add /, @, %, #, etc chars to complete list, because we already have colors
setopt NO_LIST_TYPES
# Wait 10s for every command ending with *
setopt RM_STAR_WAIT

# GENERAL
# Selected completion is hilighted
zstyle ':completion:*' menu select
# Use LS_COLORS to suggest completions
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# Display completion suggestion in various groups (files, command, etc)
zstyle ':completion:*' group-name ''
# Format of the group title
zstyle ':completion:*:descriptions' format '----- %B%d%b -----'
# Display verbose information about the completion being done
zstyle ':completion:*' verbose yes
# Warning message when no match found
zstyle ':completion:*:warnings' format 'No matches for: %d'
# Message when displaying a hint on an command argument
zstyle ':completion:*:messages' format '%d'

# Completion will first try to complete and if nothing is found will try to
# spell-check instead
zstyle ':completion:::::' completer _complete _correct
# Only suggest the more common users
# zstyle ":completion:*" users $USER admin root www-data
# Matching is case insensitive, and match even in middle of word
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'

# Enable fasd
eval "$(fasd --init auto)"




# TODO : Check the usefulness of the following options
# Background processes aren't killed on exit of shell
# setopt AUTO_CONTINUE
# The following lines were added by compinstall
# zstyle ':completion:*' completer _expand _complete _match
# zstyle ':completion:*' completions 0
# zstyle ':completion:*' format 'Completing %d'
# zstyle ':completion:*' glob 0
# zstyle ':completion:*' group-name ''
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' matcher-list '+m:{a-z}={A-Z} r:|[._-]=** r:|=**' '' '' '+
# m:{a-z}={A-Z} r:|[._-]=** r:|=**'
# zstyle ':completion:*' max-errors 1 numeric
# zstyle ':completion:*' substitute 0
# zstyle :compinstall filename "$HOME/.zshrc"
