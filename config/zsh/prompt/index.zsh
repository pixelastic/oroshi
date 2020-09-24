local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Set current path as the window title
function chpwd() {
  print -Pn "\e]2;%~/\a"
}

source $zshConfigDir/prompt/left.zsh
source $zshConfigDir/prompt/right.zsh

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
