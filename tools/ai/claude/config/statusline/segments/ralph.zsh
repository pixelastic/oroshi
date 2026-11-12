# Statusline ralph segment: the plan badge of the current directory, followed
# by the ralph auto icon when the plan runs in auto mode
# REPLY is empty when there is no plan directory or no badge
# Usage:
# $ getRalphSegment ~/www/worktrees/foo  # REPLY holds the plan badge and the auto icon
function getRalphSegment() {
  local currentDir="$1"

  REPLY=""

  icons-load-definitions
  colors-load-definitions

  local planDirectory="$(plan-directory "$currentDir")"

  # No plan: no segment
  [[ "$planDirectory" == "" ]] && return 0

  local planBadge="$(plan-badge "$planDirectory")"

  # No badge: no segment
  [[ "$planBadge" == "" ]] && return 0

  REPLY="$planBadge"

  # Only the auto mode adds an icon
  [[ "$(ralph-mode "$planDirectory")" != "auto" ]] && return 0

  colorize --reply "$ICONS[ralph-auto]" "ralph-auto"
  REPLY="$planBadge"$'\u00a0'"$REPLY"
}
