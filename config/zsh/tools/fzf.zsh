# FZF {{{
# Default config
# Note: Colors are defined in theming/fzf.zsh
export FZF_DEFAULT_OPTS=""
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --ansi"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --keep-right"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --border"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=90%"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --preview-window=down"

# Command to find files
export FZF_DEFAULT_COMMAND='f --color always --type file'
# Specific command when opended with Ctrl-P
export FZF_CTRL_T_OPTS=""
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --preview 'fzf-preview {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# }}}
