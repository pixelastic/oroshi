# FZF
function () {
  # Stop if fzf not installed
  local fzfPath=~/.fzf.zsh
  [[ -r $fzfPath ]] || return
  source $fzfPath

  # Default config
  export FZF_DEFAULT_OPTS=""
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --keep-right"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --border"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height=90%"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --preview-window=right"
  # UI
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color border:$COLOR_ALIAS_UI"               # Border all around
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color prompt:$COLOR_ALIAS_UI"               # > at the start of the input
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color info:$COLOR_ALIAS_NUMBER"             # Result count
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color gutter:-1"                            # gutter on the left
  # Current line
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color pointer:$COLOR_ALIAS_UI"              # > at the start of the current line
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color bg+:$COLOR_ALIAS_SELECTED_BACKGROUND" # background of current line
  # Match
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl:reverse:$COLOR_ALIAS_MATCH"        # match
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color hl+:reverse:$COLOR_ALIAS_MATCH"       # match in current line
  # Unused
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color header:$COLOR_ALIAS_UNKNOWN"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color spinner:$COLOR_ALIAS_UNKNOWN"
}


