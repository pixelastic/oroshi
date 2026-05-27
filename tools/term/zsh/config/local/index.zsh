# Local custom local config
local localConfig=$ZSH_CONFIG_PATH/local/${HOSTNAME}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=~/.oroshi/private/config/term/zsh/local/${HOSTNAME}/index.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
