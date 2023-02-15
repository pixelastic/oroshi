# Loading gitstatus. It can't be loaded from inside a require
source /home/tim/local/etc/gitstatus/gitstatus.plugin.zsh

require 'env'               # Global environment variables
require 'path'              # Definition of $PATH
require 'tmux'              # Tmux load
require 'theming/index'     # Colors

require 'history'           # History of commands
require 'aliases/index'     # Aliases definitions
require 'tools/index'       # Tools (nvm, bat, rg, fzf, etc) configuration
require 'keybindings/index' # Ctrl-G, Ctrl-P, etc
require 'completion/index'  # Autocompletion
require 'prompt/index'      # Prompt display

require 'local/index'       # Laptop-specific configuration
