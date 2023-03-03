# FZF
function oroshi_tools_fzf() {
  # Stop if fzf not installed
  local fzfPath=~/.fzf.zsh
  [[ -r $fzfPath ]] || return
  source $fzfPath

  # Colors
  local fzfColors=()
  fzfColors+=("info:$COLOR_ALIAS_NUMBER")                 # result count
  fzfColors+=("prompt:$COLOR_ALIAS_UI")                   # > before query
  fzfColors+=("bg+:$COLOR_ALIAS_SELECTED_BACKGROUND")     # selected result background
  fzfColors+=("fg+:$COLOR_ALIAS_SELECTED_FOREGROUND")     # selected result foreground
  fzfColors+=("pointer:$COLOR_ALIAS_POINTER")             #  before current line
  fzfColors+=("marker:$COLOR_ALIAS_MARKER")               #  before selected result
  fzfColors+=("hl:reverse:$COLOR_ALIAS_MATCH")            # match
  fzfColors+=("hl+:reverse:$COLOR_ALIAS_MATCH")           # match in current line
  fzfColors+=("gutter:-1")                                # suggestion gutter
  local fzfOptionColors="--color '${fzfColors:gs/ /,}'"

  # Preview window
  local fzfOptionPreview="\
    --preview-window 'right,50%,border-left,<79(bottom,50%,border-top)' \
    --bind 'ctrl-j:preview-down' \
    --bind 'ctrl-k:preview-up' \
  "
  # Multi-select options
  local fzfOptionsMulti="\
    --multi \
    --marker= \
    --bind 'ctrl-space:toggle+down' \
    --bind 'ctrl-a:toggle-all' \
  "

  # Generic options
  local fzfOptionBase="\
    --ansi \
    --pointer= \
    --reverse \
    --cycle \
    --keep-right \
    --bind 'tab:down' \
    --bind 'ctrl-l:clear-query' \
  "

  # Default config
  export FZF_DEFAULT_OPTS="$fzfOptionBase $fzfOptionsMulti $fzfOptionColors $fzfOptionPreview"
}
oroshi_tools_fzf
unfunction oroshi_tools_fzf


