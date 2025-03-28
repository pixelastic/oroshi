# Ctrl-E to edit the line in Vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line
