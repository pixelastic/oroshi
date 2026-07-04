# FZF
function oroshi_tools_fzf() {
  # Stop if fzf not installed
  local fzfPath=~/.fzf.zsh
  [[ ! -r $fzfPath ]] && return
  source $fzfPath

  source "$OROSHI_ROOT/scripts/bin/fzf/__lib/fzf-set-default-opts.zsh"
  fzf-set-default-opts
}
oroshi_tools_fzf
unfunction oroshi_tools_fzf
