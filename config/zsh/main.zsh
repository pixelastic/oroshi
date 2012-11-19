# main.zsh
# ~/.zshrc points to this file which will in turn load every zsh config fits
# for and interactive shell as well as host-specific configs

local currentDir="`pwd`"
local configDir=~/.oroshi/config/zsh

# Move to the zsh config dir
cd $configDir
source ./filetypes.zsh
source ./history.zsh
source ./keybindings.zsh
source ./vimode.zsh
source ./completion.zsh
source ./aliases.zsh

# Local file
# Note: Needs to be loaded here so it can overwrite default alias but still
# contains config options needed for prompt theming
local localConfig=${configDir}/local/$(hostname).zsh
if [[ -r $localConfig ]]; then
	typeset -A promptColor
	source $localConfig
fi

source ./theming.zsh
source ./prompt.zsh

# Clean the path to remove duplicates
typeset -U path

# Move back to original dir
cd $currentDir
