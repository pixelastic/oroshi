#!/usr/bin/env zsh
# Render the Claude Code statusline with context, cost, model, sub-agent, mcp, plan and ralph auto badges
# The mcp badge lists the servers connected in the session, read from the transcript at `transcript_path`
# Usage:
# $ statusline < status.json  # Render from the Claude Code statusLine JSON
# $ statusline --dry-run      # Render with fake session data
set -e

# Load icon and color definitions
icons-load-definitions
colors-load-definitions

# Load the segments, in an explicit list
local segmentsDirectory="$OROSHI_ROOT/tools/ai/claude/config/statusline/segments"
for segmentName in context cost model subagent; do
  source "$segmentsDirectory/$segmentName.zsh"
done

# Real values from files, fake values for session data
if [[ "$1" == "--dry-run" ]]; then
  local currentDir="$PWD"
  local modelName="Sonnet 4.6"
  local totalCost=0
  local totalTokens=51000
  local contextPercentage=24
  local sessionId=""
  local transcriptPath=""
else
  local stdinData=$(cat)
  local currentDir=$(echo "$stdinData" | jq -r '.workspace.current_dir')
  local modelName=$(echo "$stdinData" | jq -r '.model.display_name')
  local totalCost=$(echo "$stdinData" | jq -r '.cost.total_cost_usd // 0 | . * 10000 | round / 10000')
  local totalTokens=$(echo "$stdinData" | jq -r '.context_window.current_usage | (.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)')
  local contextPercentage=$(echo "$stdinData" | jq -r '.context_window.used_percentage // 0')
  local sessionId=$(echo "$stdinData" | jq -r '.session_id // ""')
  local transcriptPath=$(echo "$stdinData" | jq -r '.transcript_path // ""')
fi

local statusline=()

# Unused info {{{
# Model (effort)
# local settingsFile=~/.claude/settings.json
# local effortLevel=$(jq -r '.effortLevel // "medium"' "$settingsFile")
# }}}

# Context (badge and token budget)
getContextSegment \
  --total-tokens "$totalTokens" \
  --context-percentage "$contextPercentage" \
  --current-dir "$currentDir"
[[ "$REPLY" != "" ]] && statusline+=("$REPLY")

# Cost
getCostSegment "$totalCost"
[[ "$REPLY" != "" ]] && statusline+=("$REPLY")

# Model
getModelSegment "$modelName"
[[ "$REPLY" != "" ]] && statusline+=("$REPLY")

# Sub-agent dots
getSubagentSegment "$sessionId"
[[ "$REPLY" != "" ]] && statusline+=("$REPLY")

# Session ID
# local displaySession="$(colorize "[${sessionId}]" $COLORS[claude-sessionId])"
# statusline+=("$displaySession")

# MCP Servers
local mcpBadge="$(claude-mcp-badge "$transcriptPath")"
[[ "$mcpBadge" != "" ]] && statusline+=("$mcpBadge _")

# Ralph plan progress
local planDirectory="$(plan-directory "$currentDir")"
local planBadge="$(plan-badge "$planDirectory")"
[[ "$planBadge" != "" ]] && statusline+=("$planBadge")

# Ralph auto mode
local ralphMode=""
[[ "$planDirectory" != "" ]] && ralphMode="$(ralph-mode "$planDirectory")"
[[ "$ralphMode" == "auto" ]] && statusline+=("$(colorize "$ICONS[ralph-auto]" $COLORS[ralph-auto])")

# Join the non-empty segments with a no-break space
local separator=$'\u00a0'
print "${(pj:$separator:)statusline}"
