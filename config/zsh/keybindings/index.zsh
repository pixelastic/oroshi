# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

require 'keybindings/clean.zsh'
require 'keybindings/vim.zsh'
require 'keybindings/ctrl-e.zsh' # Edit line in vim
require 'keybindings/ctrl-f.zsh' # Fuzzy-find absolute files (output as full path instead of relative)
require 'keybindings/ctrl-j.zsh' # Fuzzy-find common directories
require 'keybindings/ctrl-n.zsh' # Open current directory in Nautilus
require 'keybindings/ctrl-o.zsh' # Fuzzy-find directories
require 'keybindings/ctrl-p.zsh' # Fuzzy-find relative files
require 'keybindings/ctrl-r.zsh' # Fuzzy-find history commands
require 'keybindings/ctrl-y.zsh' # Fuzzy-find all git commits hashes
