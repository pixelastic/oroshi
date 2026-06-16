# FZF Script init — source at the top of FZF scripts (before other libs)
# Parses standard flags (--source, --options, --postprocess), defines fzf-main
# Usage: source "${0:h}/__lib/init.zsh"

zmodload zsh/zutil
zparseopts -D -E \
  -source=flagSource \
  -options=flagOptions \
  -postprocess=flagPostprocess

local isSource=${#flagSource}
local isOptions=${#flagOptions}
local isPostprocess=${#flagPostprocess}

fzf-main() {
  if [[ $isSource == "1" ]]; then fzf-source; return 0; fi
  if [[ $isOptions == "1" ]]; then fzf-options; return 0; fi
  if [[ $isPostprocess == "1" ]]; then fzf-postprocess; return 0; fi
  local opts=(${(f)"$(fzf-options)"})
  fzf-source | fzf "${opts[@]}" | fzf-postprocess
}
