# Only source this file for interactive shells
[[ $- != *i* ]] && return

export ZSH_SOURCE_TIMER=1 # Set to 1 to show source timing
export ZSH_PROMPT_TIMER=0 # Set to 1 to show prompt timing

source ~/.oroshi/config/zsh/debug.zsh
source ~/.oroshi/config/zsh/require.zsh

# Setting env variables
require 'env.zsh'
require 'tmux.zsh'
require 'theming/index.zsh'

require 'completion/index.zsh'
require 'history.zsh'
require 'aliases.zsh'
require 'tools/index.zsh'
require 'keybindings/index.zsh'
require 'prompt/index.zsh'

require 'local/index.zsh'

if [[ $ZSH_SOURCE_TIMER == '1' ]]; then
  oroshi_debug_source_timer
fi
