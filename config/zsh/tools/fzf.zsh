# FZF
function () {
  # Stop if fzf not installed
  local fzfPath=~/.fzf.zsh
  [[ -r $fzfPath ]] || return
  source $fzfPath

  # Colors
  local fzfColors=()
  fzfColors+=("info:$COLOR_ALIAS_NUMBER") # result count
  fzfColors+=("prompt:$COLOR_ALIAS_UI") # > before query
  fzfColors+=("pointer:$COLOR_ALIAS_UI") # > before selected result
  fzfColors+=("bg+:$COLOR_ALIAS_SELECTED_BACKGROUND") # selected result background
  fzfColors+=("fg+:$COLOR_ALIAS_SELECTED_FOREGROUND") # selected result foreground
  fzfColors+=("hl:reverse:$COLOR_ALIAS_MATCH") # match
  fzfColors+=("hl+:reverse:$COLOR_ALIAS_MATCH") # match in current line
  fzfColors+=("gutter:-1") # suggestion gutter
  local fzfOptionColors="--color '${fzfColors:gs/ /,}'"

  # Preview window
  local fzfOptionPreview="\
    --preview-window 'right,50%,border-left,<79(bottom,50%,border-top)' \
  "

  # Generic options
  local fzfOptionBase="\
    --reverse \
    --keep-right \
  "

  # Default config
  export FZF_DEFAULT_OPTS="$fzfOptionBase $fzfOptionColors $fzfOptionPreview"
}


