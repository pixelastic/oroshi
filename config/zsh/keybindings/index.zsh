# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

require 'keybindings/clean'
require 'keybindings/vim'
require 'keybindings/ctrl-e' # Edit line in vim
require 'keybindings/ctrl-f' # Fuzzy-find absolute files (output as full path instead of relative)
require 'keybindings/ctrl-j' # Fuzzy-find common directories
require 'keybindings/ctrl-n' # Open current directory in Nautilus
require 'keybindings/ctrl-o' # Fuzzy-find directories
require 'keybindings/ctrl-g' # Search in files
require 'keybindings/ctrl-p' # Fuzzy-find relative files
require 'keybindings/ctrl-r' # Fuzzy-find history commands
require 'keybindings/ctrl-y' # Fuzzy-find all git commits hashes
