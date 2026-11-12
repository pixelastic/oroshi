# Statusline MCP segment: the connected MCP servers of a Claude session
# Servers are shown under their alias (claude-mcp-<name> icon), or their raw
# name when they have none, joined by spaces
# REPLY is empty when no server is connected
# Usage:
# $ getMcpSegment ~/.claude/projects/foo/abc.jsonl  # REPLY holds the server badges
function getMcpSegment() {
  local transcriptPath="$1"

  REPLY=""

  icons-load-definitions
  colors-load-definitions

  local servers="$(claude-transcript-mcp-list-raw "$transcriptPath")"

  # No connected server: no segment
  [[ "$servers" == "" ]] && return 0

  local names=()
  for server in ${(f)servers}; do
    colorize --reply "${ICONS[claude-mcp-${server}]:-$server}" "claude-mcp"
    names+=("$REPLY")
  done
  REPLY="${(j: :)names}"
}
