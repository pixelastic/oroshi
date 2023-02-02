# Only source this file for interactive shells
[[ $- != *i* ]] && return

export ZSH_SOURCE_TIMER=0 # Set to 1 to show source timing
export ZSH_PROMPT_TIMER=0 # Set to 1 to show prompt timing

# Setting env variables
require 'env'
require 'path'
require 'tmux'
require 'theming/index'

require 'completion/index'
require 'history'
require 'aliases'
require 'tools/index'
require 'keybindings/index'
require 'prompt/index'

require 'local/index'

if [[ $ZSH_SOURCE_TIMER == '1' ]]; then
  oroshi_debug_source_timer
fi
