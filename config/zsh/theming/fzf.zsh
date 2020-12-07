# UI
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color border:$COLOR[red5]" # Border all around
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color prompt:$COLOR[white]" # > at the start of the input
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color info:$COLOR[yellow]" # Result count
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color gutter:-1" # gutter on the left
# Current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color pointer:$COLOR[gray8]" # > at the start of the current line
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color bg+:$COLOR[gray9]" # background of current line
# Match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl:reverse:$COLOR[yellow]" # match
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl+:reverse:$COLOR[yellow]" # match in current line
# Unused
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color header:$COLOR[red]"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color spinner:$COLOR[red]"
