# Only source this file for interactive shells
[[ $- != *i* ]] && return

export ZSH_SOURCE_TIMER=0 # Set to 1 to show source timing
export ZSH_PROMPT_TIMER=0 # Set to 1 to show prompt timing

source ~/.oroshi/config/zsh/require.zsh

# Setting env variables
require 'env.zsh'
require 'tmux.zsh'
# The COLORS, PROJECTS and FILETYPES constants are used in many other config
# files so it should be sourced early.
source ~/.oroshi/config/zsh/theming/colors.zsh
source ~/.oroshi/config/zsh/theming/filetypes.zsh
source ~/.oroshi/config/zsh/theming/projects.zsh

require 'completion/index.zsh'
require 'history.zsh'
require 'aliases.zsh'
require 'keybindings.zsh'
require 'tools/index.zsh'
require 'prompt/index.zsh'

require 'local/index.zsh'
require 'theming/index.zsh'
