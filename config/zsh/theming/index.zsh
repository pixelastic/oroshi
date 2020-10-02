local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

source $zshConfigDir/theming/ls.zsh
source $zshConfigDir/theming/exa.zsh
source $zshConfigDir/theming/highlight.zsh
source $zshConfigDir/theming/bat.zsh
source $zshConfigDir/theming/manpage.zsh
source $zshConfigDir/theming/fzf.zsh

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
