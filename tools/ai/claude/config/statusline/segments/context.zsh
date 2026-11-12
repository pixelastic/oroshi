# Statusline context segment: context badge followed by the token budget, colored by percentage
# Usage:
# $ getContextSegment --total-tokens 51000 --context-percentage 24 --current-dir "$PWD"
function getContextSegment() {
  zparseopts -E -D \
    -total-tokens:=flagTotalTokens \
    -context-percentage:=flagContextPercentage \
    -current-dir:=flagCurrentDir

  local totalTokens=${flagTotalTokens[2]}
  local contextPercentage=${flagContextPercentage[2]}
  local currentDir=${flagCurrentDir[2]}

  colors-load-definitions

  # Context budget
  local tokensKRaw=$(printf "%.1f" $((totalTokens / 1000.0)))
  local tokensK="${tokensKRaw%\.0}k"
  local contextColor=$COLORS[claude-contextHigh]
  ((contextPercentage < 60)) && contextColor=$COLORS[claude-contextMedium]
  ((contextPercentage < 20)) && contextColor=$COLORS[claude-contextLow]
  REPLY="$(colorize "${tokensK}" $contextColor)"

  # Context badge, when the directory belongs to a project
  local displayBadge="$(context-badge "$currentDir")"

  # Without a badge, the token budget stands alone
  [[ "$displayBadge" == "" ]] && return 0

  REPLY="${displayBadge}"$'\u00a0'"${REPLY}"
}
