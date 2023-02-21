# Local custom local config
local hostname="$(hostname)"
local localConfig=$ZSH_CONFIG_PATH/local/${hostname}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=~/.oroshi/private/config/zsh/local/${hostname}.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
