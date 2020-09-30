# Only source this file for interactive shells
[[ $- != *i* ]] && return

# Set ZSH_DEBUG to 1 to enable timing information
local ZSH_DEBUG=0
local ZSHRC_DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

local zshConfigDir=~/.oroshi/config/zsh
source $zshConfigDir/env.zsh
source $zshConfigDir/tmux.zsh
source $zshConfigDir/theming/index.zsh
source $zshConfigDir/completion/index.zsh
source $zshConfigDir/history.zsh
source $zshConfigDir/aliases.zsh
source $zshConfigDir/keybindings.zsh
source $zshConfigDir/tools/index.zsh
source $zshConfigDir/prompt/index.zsh
source $zshConfigDir/local/index.zsh

local ZSHRC_DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ~/.zshrc: $(($ZSHRC_DEBUG_ENDTIME - $ZSHRC_DEBUG_STARTTIME))ms"
return 0
