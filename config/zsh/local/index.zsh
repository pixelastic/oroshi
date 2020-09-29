# Local config
# Load custom 
# Note: Needs to be loaded here so it can overwrite default alias but still
# contains config options needed for prompt theming
local localConfig=~/.oroshi/config/zsh/local/${hostname}.zsh

if [[ -r $localConfig ]]; then
  source $localConfig
fi

local privateLocalConfig=~/.oroshi/private/config/zsh/local/${hostname}.zsh
if [[ -r $privateLocalConfig ]]; then
  source $privateLocalConfig
fi
# }}}
