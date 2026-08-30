# FZF Script init — source at the top of FZF scripts (before other libs)
# Parses standard flags (--source, --options, --postprocess, --preview, --no-dispatch)
# Defines fzf-main (default pipeline, overridable) and fzf-dispatch (dispatcher)
# Scripts call fzf-dispatch at the bottom; override fzf-main for custom pipelines
# Usage: source "${0:h}/__lib/init.zsh"

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

# Default preview — no-op; scripts can override by redefining after sourcing
function fzf-preview() { return 0; }

# Default postprocess — scripts can override by redefining after sourcing
function fzf-postprocess() {
  local input="$(\cat)"
  [[ "$input" == "" ]] && return 0
  local line
  for line in ${(f)input}; do
    local -a parts=(${(@ps/▮/)line})
    print -- "$parts[1]"
  done
}

# Default pipeline — scripts can override this after sourcing
function fzf-main() {
  local opts=(${(f)"$(fzf-options)"})
  fzf-source | fzf "${opts[@]}" | fzf-postprocess
}

# Dispatcher — handles standard flags, falls through to fzf-main
function fzf-dispatch() {
  # --no-dispatch: define functions without executing (for testing)
  if [[ $isNoDispatch == "1" ]]; then return 0; fi
  if [[ $isSource == "1" ]]; then fzf-source; return 0; fi
  if [[ $isOptions == "1" ]]; then fzf-options; return 0; fi
  if [[ $isPostprocess == "1" ]]; then fzf-postprocess; return 0; fi
  if [[ $isPreview == "1" ]]; then fzf-preview "${ARGS[@]}"; return 0; fi
  fzf-main
}
