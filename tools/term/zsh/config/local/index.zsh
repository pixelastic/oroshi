# Local custom local config
local localConfig=${0:A:h}/${HOSTNAME}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=~/.oroshi/private/config/term/zsh/local/${HOSTNAME}/index.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
