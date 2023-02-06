# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

require 'keybindings/clean'
require 'keybindings/vim'
require 'keybindings/ctrl-e'       # Edit line in vim
require 'keybindings/ctrl-n'       # Open current directory in Nautilus

require 'keybindings/ctrl-g'       # Regexp search in files in project
require 'keybindings/ctrl-shift-g' # Regexp search in files in subdir

require 'keybindings/ctrl-p'       # Fuzzy-find files in project
require 'keybindings/ctrl-shift-p' # Fuzzy-find files in subdirectories

require 'keybindings/ctrl-j'       # Fuzzy-find common directories

require 'keybindings/ctrl-h'       # Fuzzy-find all git commits hashes
require 'keybindings/ctrl-r'       # Fuzzy-find history commands

