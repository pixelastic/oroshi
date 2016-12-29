# Only source this file for interactive shells
if [[ $- != *i* ]]; then
  return
fi

local hostname="$(hostname)"
local zshConfigDir=~/.oroshi/config/zsh

# Environment variables {{{
export EDITOR=vim
export CHROME_BIN=/usr/bin/google-chrome
export BROWSER=/usr/bin/google-chrome
export LANG=en_US.UTF-8
export TERM=screen-256color
path=(
  ~/.oroshi/scripts/bin
  ~/.oroshi/scripts/bin/vit/bin
  ~/.oroshi/scripts/bin/img/bin
  ~/.oroshi/scripts/bin/pdf/bin
  ~/.oroshi/private/scripts/bin
  ~/.oroshi/scripts/bin/local/$hostname
  ~/.oroshi/private/scripts/bin/local/$hostname
  $HOME/.rvm/bin
  ~/local/bin
  $path
  ~/.local/bin
)
typeset -U path
# }}}

# We start a new tmux session if none already started
source $zshConfigDir/tmux.zsh

# Some stuff must be set before everything else
source $zshConfigDir/first.zsh

# Configuration
source $zshConfigDir/filetypes.zsh
source $zshConfigDir/history.zsh
source $zshConfigDir/aliases.zsh
source $zshConfigDir/completion.zsh
source $zshConfigDir/keybindings.zsh

# Local config {{{
# Note: Needs to be loaded here so it can overwrite default alias but still
# contains config options needed for prompt theming
local localConfig=~/.oroshi/config/zsh/local/${hostname}.zsh
if [[ -r $localConfig ]]; then
  typeset -A promptColor
  source $localConfig
fi
local privateLocalConfig=~/.oroshi/private/config/zsh/local/${hostname}.zsh
if [[ -r $privateLocalConfig ]]; then
  source $privateLocalConfig
fi
# }}}

source $zshConfigDir/theming.zsh
source $zshConfigDir/prompt.zsh

# Some stuff must be loaded after everything else
source $zshConfigDir/last.zsh
