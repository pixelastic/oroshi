# FZF
function oroshi_tools_fzf() {
  # Stop if fzf not installed
  local fzfPath=~/.fzf.zsh
  [[ ! -r $fzfPath ]] && return
  source $fzfPath

  colors-load-definitions
  icons-load-definitions

  # Colors
  local fzfColors=()
  fzfColors+=("info:$COLORS[number]")                 # result count
  fzfColors+=("prompt:$COLORS[ui]")                   # > before query
  fzfColors+=("bg+:$COLORS[selected-background]")     # selected result background
  fzfColors+=("fg+:$COLORS[selected-foreground]")     # selected result foreground
  fzfColors+=("pointer:$COLORS[pointer]")             # $ICONS[fzf-current] before current line
  fzfColors+=("marker:$COLORS[marker]")               # $ICONS[fzf-selected] before selected result
  fzfColors+=("hl:reverse:$COLORS[match]")            # match
  fzfColors+=("hl+:reverse:$COLORS[match]")           # match in current line
  fzfColors+=("gutter:-1")                                # suggestion gutter
  local fzfOptionColors="--color '${fzfColors:gs/ /,}'"

  # Preview window
  # If the preview on the right get smaller than that number of chars, we pass
  # it in horizontal mode. Note that this number will kinda depend on the
  # font size used.
  local maxCharWidth=72
  local fzfOptionPreview="\
    --preview-window 'right,50%,border-left,<${maxCharWidth}(bottom,50%,border-top)' \
    --bind 'ctrl-j:preview-down' \
    --bind 'ctrl-k:preview-up' \
  "
  # Multi-select options
  local fzfOptionsMulti="\
    --multi \
    --marker="$ICONS[fzf-selected]" \
    --bind 'enter:accept' \
    --bind 'ctrl-space:toggle+down' \
    --bind 'ctrl-a:toggle-all' \
  "

  # Generic options
  local fzfOptionBase="\
    --ansi \
    --pointer=$ICONS[fzf-current] \
    --reverse \
    --cycle \
    --keep-right \
    --no-hscroll \
    --bind 'tab:down' \
    --bind 'shift-up:half-page-up' \
    --bind 'shift-down:half-page-down' \
    --bind 'home:first' \
    --bind 'end:last' \
    --bind 'ctrl-l:clear-query+first' \
    --bind 'bspace:backward-delete-char+first' \
  "

  # Default config
  export FZF_DEFAULT_OPTS="$fzfOptionBase $fzfOptionsMulti $fzfOptionColors $fzfOptionPreview"
}
oroshi_tools_fzf
unfunction oroshi_tools_fzf
