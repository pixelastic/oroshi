# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

local keybindingsDir="$OROSHI_ROOT/tools/term/zsh/config/keybindings"

source $keybindingsDir/vim.zsh

source $keybindingsDir/shift-enter.zsh # Add new line
source $keybindingsDir/ctrl-space.zsh  # Add completion item
source $keybindingsDir/tab.zsh         # Completion

source $keybindingsDir/ctrl-a.zsh       # Accept all suggestions
source $keybindingsDir/ctrl-e.zsh       # Edit line in vim
source $keybindingsDir/ctrl-r.zsh       # Fuzzy-find history commands
source $keybindingsDir/ctrl-y.zsh       # Copy current directory to clipboard
source $keybindingsDir/ctrl-shift-y.zsh # Copy last command + output to clipboard
source $keybindingsDir/ctrl-i.zsh       # Open Claude Code
source $keybindingsDir/ctrl-shift-i.zsh # Fuzzy-find Claude sessions
source $keybindingsDir/ctrl-o.zsh       # Fuzzy-find directories in project
source $keybindingsDir/ctrl-shift-o.zsh # Fuzzy-find directories in subdir
source $keybindingsDir/ctrl-p.zsh       # Fuzzy-find files in project
source $keybindingsDir/ctrl-shift-p.zsh # Fuzzy-find files in subdirectories

source $keybindingsDir/ctrl-g.zsh       # Regexp search in files in project
source $keybindingsDir/ctrl-shift-g.zsh # Regexp search in files in subdir
source $keybindingsDir/ctrl-l.zsh       # List all files in directory
source $keybindingsDir/ctrl-shift-l.zsh # Clear terminal

source $keybindingsDir/ctrl-b.zsh             # Fuzzy-find binaries in $PATH
source $keybindingsDir/ctrl-n.zsh             # Open current directory in Nautilus
source $keybindingsDir/ctrl-question-mark.zsh # Explain what the current command does

# }}}

source $keybindingsDir/clean.zsh
