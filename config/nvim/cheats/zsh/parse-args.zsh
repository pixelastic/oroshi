# Parse arguments (argsf, argsp)

# ====
# https://xpmo.gitlab.io/post/using-zparseopts/
# https://linux.die.net/man/1/zshmodules
zmodload zsh/zutil
# -E : Don't stop on unknown flags
# -D : $@ is updated by removing all found flags
zparseopts \
  -E \
  -D \
  -highlight-line:=flagHighlightLine \
  -highlight-query:=flagHighlightQuery \

local highlightLine=${flagHighlightLine[2]}
local highlightQuery=${flagHighlightQuery[2]}
# ===
