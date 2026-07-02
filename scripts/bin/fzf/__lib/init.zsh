# FZF Script init — source at the top of FZF scripts (before other libs)
# Parses standard flags (--source, --options, --postprocess, --preview, --no-dispatch)
# Defines fzf-main (default pipeline, overridable) and fzf-dispatch (dispatcher)
# Scripts call fzf-dispatch at the bottom; override fzf-main for custom pipelines
# Usage: source "${0:h}/__lib/init.zsh"

zmodload zsh/zutil
zparseopts -D -E \
  -source=flagSource \
  -options=flagOptions \
  -postprocess=flagPostprocess \
  -preview=flagPreview \
  -no-dispatch=flagNoDispatch

local isSource=${#flagSource}
local isOptions=${#flagOptions}
local isPostprocess=${#flagPostprocess}
local isPreview=${#flagPreview}
local isNoDispatch=${#flagNoDispatch}
ARGS=("$@")

# Default pipeline — scripts can override this after sourcing
fzf-main() {
  local opts=(${(f)"$(fzf-options)"})
  fzf-source | fzf "${opts[@]}" | fzf-postprocess
}

# Dispatcher — handles standard flags, falls through to fzf-main
fzf-dispatch() {
  # --no-dispatch: define functions without executing (for testing)
  if [[ $isNoDispatch == "1" ]]; then return 0; fi
  if [[ $isSource == "1" ]]; then fzf-source; return 0; fi
  if [[ $isOptions == "1" ]]; then fzf-options; return 0; fi
  if [[ $isPostprocess == "1" ]]; then fzf-postprocess; return 0; fi
  if [[ $isPreview == "1" ]]; then fzf-preview "${ARGS[@]}"; return 0; fi
  fzf-main
}
