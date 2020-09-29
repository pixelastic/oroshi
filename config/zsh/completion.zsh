local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# Add path to custom completion methods
fpath=(~/.oroshi/config/zsh/completion $fpath)
typeset -U fpath # Deduplicate entries

autoload -Uz compinit
zmodload zsh/complist

# Regenerate the .zcompdump file only once a day instead at on each new zsh
# window. This takes ~300ms
# See: https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
# }}}

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
# When COMPLETE_ALIASES is set (default), any alias is considered a new command,
# so loses all built-in completion for the command it is aliases to. We unset
# it, so alias g='git' correctly handle git autocompletion
# The downsite is that if we define a custom alias yrt="yarn run test",
# completion for yrt will be the same as completion for yarn. To add custom
# completion, we need to create a new bin (yrt) instead of an alias and define
# completion for it
unsetopt COMPLETE_ALIASES
# Wait 10s before rm ./*
setopt RM_STAR_WAIT

local zshConfigDir=~/.oroshi/config/zsh
source $zshConfigDir/completion/yl
source $zshConfigDir/completion/ylR
source $zshConfigDir/completion/yr
source $zshConfigDir/completion/yu
source $zshConfigDir/completion/tmuxinator
source $zshConfigDir/completion/_docker-container-all
# source $zshConfigDir/completion/_docker-container-running
# source $zshConfigDir/completion/_docker-container-stopped
source $zshConfigDir/completion/_docker-images
source $zshConfigDir/completion/_git-branches
source $zshConfigDir/completion/_git-files
source $zshConfigDir/completion/_git-remotes
source $zshConfigDir/completion/_git-tags
source $zshConfigDir/completion/mark
source $zshConfigDir/completion/kubectl.zsh
source $zshConfigDir/completion/gcp.zsh

# Auto escape &, ? and * when needed
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# What to complete... {{{
# Try to complete first, and then correct
zstyle ':completion:*' completer _complete _correct
# Search for completion in the whole filename, not just on the start
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# }}}

# How to display completion... {{{
# File completion is colored
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Selected file is highlighted
zstyle ':completion:*' menu select
# Completion type separator
zstyle ':completion:*:descriptions' format '%F{069} %d%f'
# No completion found
zstyle ':completion:*:warnings' format '%F{136}  No completion found%f'
zstyle ':completion:*:messages' format '%F{136}  %d%f'
# Do not add trailing / to dirs or @ to symlinks
unsetopt LIST_TYPES
# Display suggestions horizontally
setopt LIST_ROWS_FIRST
# }}}

# Debug method to reload the completion functions {{{
function reloadCompletion() {
  unfunction $1
  autoload -U $1
}

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
