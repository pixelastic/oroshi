# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

source $ZSH_CONFIG_PATH/keybindings/vim.zsh

source $ZSH_CONFIG_PATH/keybindings/tab.zsh                # Completion
source $ZSH_CONFIG_PATH/keybindings/ctrl-space.zsh         # Add completion item
source $ZSH_CONFIG_PATH/keybindings/ctrl-a.zsh             # Accept all suggestions
source $ZSH_CONFIG_PATH/keybindings/ctrl-e.zsh             # Edit line in vim
source $ZSH_CONFIG_PATH/keybindings/ctrl-l.zsh             # List all files in directory
source $ZSH_CONFIG_PATH/keybindings/ctrl-shift-l.zsh       # Clear terminal
source $ZSH_CONFIG_PATH/keybindings/ctrl-n.zsh             # Open current directory in Nautilus
source $ZSH_CONFIG_PATH/keybindings/ctrl-question-mark.zsh # Explain what the current command does
source $ZSH_CONFIG_PATH/keybindings/ctrl-i.zsh             # Open an AI chat
source $ZSH_CONFIG_PATH/keybindings/ctrl-p.zsh             # Fuzzy-find files in project
source $ZSH_CONFIG_PATH/keybindings/ctrl-shift-p.zsh       # Fuzzy-find files in subdirectories
source $ZSH_CONFIG_PATH/keybindings/ctrl-t.zsh             # Fuzzy-find files in subdirectories (same as Ctrl-Shift-p)
source $ZSH_CONFIG_PATH/keybindings/ctrl-o.zsh             # Fuzzy-find directories in project
source $ZSH_CONFIG_PATH/keybindings/ctrl-shift-o.zsh       # Fuzzy-find directories in subdir
source $ZSH_CONFIG_PATH/keybindings/ctrl-g.zsh             # Regexp search in files in project
source $ZSH_CONFIG_PATH/keybindings/ctrl-shift-g.zsh       # Regexp search in files in subdir
source $ZSH_CONFIG_PATH/keybindings/ctrl-j.zsh             # Fuzzy-find common directories
source $ZSH_CONFIG_PATH/keybindings/ctrl-h.zsh             # Fuzzy-find all git commits hashes
source $ZSH_CONFIG_PATH/keybindings/ctrl-r.zsh             # Fuzzy-find history commands
source $ZSH_CONFIG_PATH/keybindings/ctrl-b.zsh             # Fuzzy-find binaries in $PATH

source $ZSH_CONFIG_PATH/keybindings/clean.zsh
