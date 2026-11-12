# Statusline model segment: the model display name
# Usage:
# $ getModelSegment "Sonnet 4.6"  # REPLY is the colored model name
function getModelSegment() {
  local modelName="$1"

  colors-load-definitions

  REPLY="$(colorize "${modelName}" $COLORS[claude-model])"
}
