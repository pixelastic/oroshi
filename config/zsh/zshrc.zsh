# Only source this file for interactive shells
if [[ $- != *i* ]]; then
  return
fi

# Set ZSH_DEBUG to 1 to enable timing information
local ZSH_DEBUG=0
local ZSHRC_DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

local hostname="$(hostname)"
local zshConfigDir=~/.oroshi/config/zsh

# Environment variables {{{
export EDITOR=vim
export CHROME_BIN=/usr/bin/google-chrome
export BROWSER=/usr/bin/google-chrome
export LANG=en_US.UTF-8
# This needs to be set to the same value as the default-terminal in tmux.conf
export TERM=xterm-256color
path=(
  # yarn global executable is here
  ~/.yarn/bin 
  ~/.rvm/bin
  ~/.cargo/bin
  ~/.linuxbrew/bin
  ~/.linuxbrew/sbin
  ~/.oroshi/scripts/bin
  ~/.oroshi/scripts/bin/vit/bin
  ~/.oroshi/scripts/bin/img/bin
  ~/.oroshi/scripts/bin/video/bin
  ~/.oroshi/scripts/bin/pdf/bin
  ~/.oroshi/scripts/bin/convert/bin
  ~/.oroshi/scripts/bin/coriolis/bin
  ~/.oroshi/private/scripts/bin
  ~/.oroshi/scripts/bin/local/$hostname
  ~/.oroshi/private/scripts/bin/local/$hostname
  ~/local/bin
  $path
  ~/.local/bin
  # yarn globally installed modules are here
  ~/.config/yarn/global/node_modules/.bin 
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
typeset -A promptColor

if [[ -r $localConfig ]]; then
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

local ZSHRC_DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ~/.zshrc: $(($ZSHRC_DEBUG_ENDTIME - $ZSHRC_DEBUG_STARTTIME))ms"
