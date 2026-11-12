# Statusline sub-agent segment: one colorized dot per sub-agent of a Claude session
# Reads the sub-agents from statusline.json in the session directory
# REPLY is empty when the file is missing, invalid, or has no sub-agents
# Usage:
# $ getSubagentSegment abc-123  # REPLY holds the dots for session abc-123
function getSubagentSegment() {
  local sessionId="$1"

  REPLY=""

  icons-load-definitions
  colors-load-definitions

  local sessionDir="$(claude-session-dir "$sessionId")"

  # No session: no sub-agents to show
  [[ "$sessionDir" == "" ]] && return 0

  local stateFile="${sessionDir}/statusline.json"

  # Missing or invalid state file: no sub-agents to show
  [[ ! -f "$stateFile" ]] && return 0
  ! json-is-valid --input "$stateFile" && return 0

  # Pick one color key per sub-agent.
  # A pending sub-agent uses claude-subagent-pending.
  # A running review sub-agent uses its review color.
  # Special review subagents are given specific colors
  local colorKeys="$(jq --raw-output '
    .subagents // [] | .[]
    | (.description // "" | ascii_downcase) as $description
    | if .status != "running" then .status
      elif ($description | startswith("code review")) then "review-code"
      elif ($description | startswith("spec review")) then "review-spec"
      else "running"
      end
  ' "$stateFile")"

  # No sub-agents: no dots
  [[ "$colorKeys" == "" ]] && return 0

  # One dot per sub-agent
  local dots=""
  for colorKey in ${(f)colorKeys}; do
    colorize --reply "$ICONS[claude-subagent]" "claude-subagent-${colorKey}"
    dots+="$REPLY"
  done
  REPLY="$dots"
}
