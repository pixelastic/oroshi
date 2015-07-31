# TERM=xterm-256color
export LANG=en_US.UTF-8
export TERM=rxvt-unicode

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

# Move back to original dir
cd  $currentDir
