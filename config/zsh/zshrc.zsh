# Only source this file for interactive shells
[[ $- != *i* ]] && return

export ZSH_SOURCE_TIMER=0 # Set to 1 to show source timing
export ZSH_PROMPT_TIMER=0 # Set to 1 to show prompt timing

# Source a file, but also display loading time when debug is enabled
function require {
  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local before=$(/bin/date +%s%N)
  fi

  source ~/.oroshi/config/zsh/$1

  if [[ $ZSH_SOURCE_TIMER == 1 ]]; then
    local after=$(/bin/date +%s%N)

    local difference=$((($after - $before)/1000000))
    echo "$1: ${difference}ms"
  fi
}

# Setting env variables
require 'env.zsh'
require 'tmux.zsh'
# The COLORS and PROJECTS constants are used in many other config files so it
# should be loaded early. As they are using an associative array, it has to be
# `source`d directly
source ~/.oroshi/config/zsh/theming/colors.zsh
source ~/.oroshi/config/zsh/theming/projects.zsh

require 'completion/index.zsh'
require 'history.zsh'
require 'aliases.zsh'
require 'keybindings.zsh'
require 'tools/index.zsh'
require 'prompt/index.zsh'

require 'local/index.zsh'
require 'theming/index.zsh'
