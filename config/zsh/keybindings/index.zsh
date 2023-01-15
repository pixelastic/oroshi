# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: Check more ideas from https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/

require 'keybindings/clean.zsh'
require 'keybindings/vim.zsh'
require 'keybindings/ctrl-e.zsh' # Edit line in vim
require 'keybindings/ctrl-j.zsh' # Fuzzy-find common directories
require 'keybindings/ctrl-o.zsh' # Fuzzy-find directories
# require 'keybindings/ctrl-g.zsh' # TODO: Fuzzy-find all git commits hashes
require 'keybindings/ctrl-p.zsh' # Fuzzy-find relative files
# require 'keybindings/ctrl-f.zsh' # TODO: Fuzzy-find absolute files (output as full path instead of relative)
require 'keybindings/ctrl-r.zsh' # Fuzzy-find history commands
