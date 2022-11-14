# Note: Options are defined in tools/fzf.zsh
# UI
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color border:$COLORS[red5]" # Border all around
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color prompt:$COLORS[white]" # > at the start of the input
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color info:$COLORS[yellow]" # Result count
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color gutter:-1" # gutter on the left
# Current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color pointer:$COLORS[gray8]" # > at the start of the current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color bg+:$COLORS[gray9]" # background of current line
# Match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl:reverse:$COLORS[yellow]" # match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl+:reverse:$COLORS[yellow]" # match in current line
# Unused
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color header:$COLORS[red]"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color spinner:$COLORS[red]"
