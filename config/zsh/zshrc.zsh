# Only source this file for interactive shells
[[ $- != *i* ]] && return

export OROSHI_TIMER_REQUIRE=0 # Set to 1 to show source timing
export OROSHI_TIMER_PROMPT=1  # Set to 1 to show prompt timing

require 'env'               # Global environment variables
require 'path'              # Definition of $PATH
require 'tmux'              # Tmux load
require 'theming/index'     # Colors

require 'completion/index'  # Autocompletion
require 'history'           # History of commands
require 'aliases/index'     # Aliases definitions
require 'tools/index'       # Tools (nvm, bat, rg, fzf, etc) configuration
require 'keybindings/index' # Ctrl-G, Ctrl-P, etc
require 'prompt/index'      # Prompt display

require 'local/index'       # Laptop-specific configuration

# Display all source timers
oroshi-debug-timer-require
