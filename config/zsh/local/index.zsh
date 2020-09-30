local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))
# Local config
# Load custom 
# Note: Needs to be loaded here so it can overwrite default alias but still
# contains config options needed for prompt theming
local localConfig=~/.oroshi/config/zsh/local/${hostname}.zsh

[[ -r $localConfig ]] && source $localConfig

local privateLocalConfig=~/.oroshi/private/config/zsh/local/${hostname}.zsh
[[ -r $privateLocalConfig ]] && source $privateLocalConfig
# }}}
local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
