local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

source $zshConfigDir/theming/colors.zsh
source $zshConfigDir/theming/highlight.zsh
source $zshConfigDir/theming/ls.zsh
source $zshConfigDir/theming/exa.zsh
source $zshConfigDir/theming/bat.zsh
source $zshConfigDir/theming/manpage.zsh

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
