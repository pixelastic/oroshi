# Only source this file for interactive shells
if [[ $- != *i* ]]; then
  return
fi

# Environment variables {{{
export LANG=en_US.UTF-8
export TERM=xterm-256color
path=(
	~/.oroshi/scripts/bin
	~/.oroshi/private/scripts/bin
	~/.oroshi/scripts/bin/local/$(hostname)
	~/.oroshi/private/scripts/bin/local/$(hostname)
	$path
	~/local/bin
  ~/.local/bin
)
# }}}

# Launch tmux if not already launched
if [[ -z "$TMUX" ]]; then
  tmux attach || tmux new-session
  exit
fi

# Note: Lines below will only be executed when zsh is launched inside tmux
local currentDir="`pwd`"
local configDir=~/.oroshi/config/zsh

# Move to the zsh config dir
cd $configDir
source ./filetypes.zsh
source ./history.zsh
source ./completion.zsh
source ./aliases.zsh
source ./keybindings.zsh

# Local config {{{
# Note: Needs to be loaded here so it can overwrite default alias but still
# contains config options needed for prompt theming
local localConfig=${configDir}/local/$(hostname).zsh
if [[ -r $localConfig ]]; then
	typeset -A promptColor
	source $localConfig
fi
# }}}
# Private local config {{{
local privateLocalConfig=~/.oroshi/private/config/zsh/local/$(hostname).zsh
if [[ -r $privateLocalConfig ]]; then
	source $privateLocalConfig
fi
# }}}

source ./theming.zsh
source ./prompt.zsh

# Clean the path to remove duplicates
typeset -U path

# RVM {{{
# Note: This needs to be loaded at the end of the zshrc
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
	path=($HOME/.rvm/bin $path)
  source $rvmScript
  rvm use ruby-2.2.2 &>/dev/null
fi
# }}}

# Move back to original dir
cd  $currentDir
