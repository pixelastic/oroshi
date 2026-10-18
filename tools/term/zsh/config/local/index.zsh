# Local custom local config
local localConfig=${0:A:h}/${HOST}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=$OROSHI_ROOT/private/config/term/zsh/local/${HOST}/index.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
