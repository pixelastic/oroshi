# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# TODO: https://github.com/Aloxaf/fzf-tab
# TODO: https://pragmaticpineapple.com/improving-vim-workflow-with-fzf/#speed-search-your-project

source ${0:A:h}/vim.zsh

source ${0:A:h}/shift-enter.zsh # Add new line
source ${0:A:h}/ctrl-space.zsh  # Add completion item
source ${0:A:h}/tab.zsh         # Completion

source ${0:A:h}/ctrl-a.zsh       # Accept all suggestions
source ${0:A:h}/ctrl-e.zsh       # Edit line in vim
source ${0:A:h}/ctrl-r.zsh       # Fuzzy-find history commands
source ${0:A:h}/ctrl-y.zsh       # Copy current directory to clipboard
source ${0:A:h}/ctrl-shift-y.zsh # Copy last command + output to clipboard
source ${0:A:h}/ctrl-i.zsh       # Open Claude Code
source ${0:A:h}/ctrl-shift-i.zsh # Fuzzy-find Claude sessions
source ${0:A:h}/ctrl-o.zsh       # Fuzzy-find directories in project
source ${0:A:h}/ctrl-shift-o.zsh # Fuzzy-find directories in subdir
source ${0:A:h}/ctrl-p.zsh       # Fuzzy-find files in project
source ${0:A:h}/ctrl-shift-p.zsh # Fuzzy-find files in subdirectories

source ${0:A:h}/ctrl-g.zsh       # Regexp search in files in project
source ${0:A:h}/ctrl-shift-g.zsh # Regexp search in files in subdir
source ${0:A:h}/ctrl-l.zsh       # List all files in directory
source ${0:A:h}/ctrl-shift-l.zsh # Clear terminal

source ${0:A:h}/ctrl-b.zsh             # Fuzzy-find binaries in $PATH
source ${0:A:h}/ctrl-n.zsh             # Open current directory in Nautilus
source ${0:A:h}/ctrl-question-mark.zsh # Explain what the current command does

# }}}

source ${0:A:h}/clean.zsh
