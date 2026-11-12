# Statusline cost segment: cents below one dollar, dollars above
# Usage:
# $ getCostSegment 0.05  # REPLY is "5¢"
# $ getCostSegment 1.5   # REPLY is "$1.50"
function getCostSegment() {
  local totalCost="$1"

  colors-load-definitions

  REPLY=""

  # Below one dollar, show cents
  if ((totalCost < 1)); then
    local roundedCents=$((totalCost * 100 + 0.5))
    REPLY="$(colorize "${roundedCents%.*}¢" $COLORS[claude-costLow])"
    return 0
  fi

  local roundedDollars=$(printf "$%.2f" "$totalCost")
  REPLY="$(colorize "${roundedDollars}" $COLORS[claude-costHigh])"
}
