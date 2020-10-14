# FZF {{{
# Default config
# Note: Colors are defined in theming/fzf.zsh
export FZF_DEFAULT_OPTS=""
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --keep-right"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --border"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=90%"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --preview-window=down"
# Command to find files
export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'
# Specific command when opended with Ctrl-P
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# }}}
