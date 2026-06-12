# Local custom local config
local localConfig=$OROSHI_ROOT/tools/term/zsh/config/local/${HOSTNAME}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=~/.oroshi/private/config/term/zsh/local/${HOSTNAME}/index.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
