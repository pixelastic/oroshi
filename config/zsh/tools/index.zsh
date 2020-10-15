local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))
# Custom shell tools, like nvm, rvm, etc

local zshConfigDir=~/.oroshi/config/zsh
source $zshConfigDir/tools/direnv.zsh
source $zshConfigDir/tools/nvm.zsh
source $zshConfigDir/tools/pyenv.zsh
source $zshConfigDir/tools/fzf.zsh
source $zshConfigDir/tools/rg.zsh

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
