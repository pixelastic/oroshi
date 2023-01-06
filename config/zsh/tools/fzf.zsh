# FZF {{{
# Default config
export FZF_DEFAULT_OPTS=""
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --ansi"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --keep-right"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --border"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=90%"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --preview-window=down"
# UI
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color border:$COLOR_NEUTRAL" # Border all around
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color prompt:$COLOR_NEUTRAL" # > at the start of the input
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color info:$COLOR_YELLOW" # Result count
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color gutter:-1" # gutter on the left
# Current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color pointer:$COLOR_GRAY" # > at the start of the current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color bg+:$COLOR_GRAY_9" # background of current line
# Match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl:reverse:$COLOR_YELLOW" # match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl+:reverse:$COLOR_YELLOW" # match in current line
# Unused
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color header:$COLOR_RED"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color spinner:$COLOR_RED"

# Command to find files
export FZF_DEFAULT_COMMAND='f --color always --type file'
# Specific command when opended with Ctrl-P
export FZF_CTRL_T_OPTS=""
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --preview 'fzf-preview {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# }}}
