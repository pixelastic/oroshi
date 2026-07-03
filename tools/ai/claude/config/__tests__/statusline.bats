bats_load_library 'helper'

setup() {
  bats_tmp_dir

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[claude-contextHigh]=1
    COLORS[claude-contextMedium]=3
    COLORS[claude-contextLow]=8
    COLORS[claude-costLow]=6
    COLORS[claude-costHigh]=3
    COLORS[claude-model]=146
    COLORS[claude-mcp]=6
  }
  context-badge() { echo "BADGE"; }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[mcp-context7]="⬡"
  }
  bats_mock colors-load-definitions context-badge icons-load-definitions
}

statusline_json() {
  local dir="${1:-/some/dir}"
  local tokens="${2:-0}"
  local cost="${3:-0}"
  local session="${4:-test-session}"
  local contextPercentage="${5:-0}"
  cat <<EOF
{
  "workspace": { "current_dir": "$dir" },
  "model": { "display_name": "test" },
  "cost": { "total_cost_usd": $cost },
  "context_window": {
    "current_usage": {
      "input_tokens": $tokens,
      "output_tokens": 0,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    },
    "used_percentage": $contextPercentage
  },
  "session_id": "$session"
}
EOF
}

statusline_run() {
  statusline_json "$@" >"${BATS_TMP_DIR}/input.json"
  bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline" <"${BATS_TMP_DIR}/input.json"
}

@test "renders badge, tokens, cost, and model" {
  statusline_run "/some/dir" 51000 0.05 "abc-123"
  [ "$status" -eq 0 ]
  local clean
  clean="$(bats_strip_ansi "$output")"
  [[ "$clean" == "BADGE 51k 5¢ test "* ]]
}

@test "formats token count with k suffix" {
  statusline_run "/some/dir" 1000 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"1k"* ]]

  statusline_run "/some/dir" 1500 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"1.5k"* ]]

  statusline_run "/some/dir" 51000 0 "x"
  [[ "$(bats_strip_ansi "$output")" == *"51k"* ]]
}

@test "formats cost in cents or dollars" {
  statusline_run "/some/dir" 0 0.05 "x"
  [[ "$(bats_strip_ansi "$output")" == *"5¢"* ]]

  statusline_run "/some/dir" 0 1.50 "x"
  [[ "$(bats_strip_ansi "$output")" == *'$1.50'* ]]
}

@test "context color: high when >= 60%" {
  statusline_run "/some/dir" 0 0 "x" 60
  [[ "$output" == *$'\e[38;5;1m'* ]]
}

@test "context color: medium when < 60%" {
  statusline_run "/some/dir" 0 0 "x" 59
  [[ "$output" == *$'\e[38;5;3m'* ]]
}

@test "context color: low when < 20%" {
  statusline_run "/some/dir" 0 0 "x" 19
  [[ "$output" == *$'\e[38;5;8m'* ]]
}

@test "renders mcp server icon when icon exists" {
  jq() {
    local lastArg="${*[-1]}"
    [[ "$lastArg" == *".claude.json" ]] && { echo "context7"; return 0; }
    command jq "$@"
  }
  bats_mock jq
  statusline_run
  [[ "$(bats_strip_ansi "$output")" == *"⬡"* ]]
}

@test "renders mcp server name as fallback when no icon" {
  jq() {
    local lastArg="${*[-1]}"
    [[ "$lastArg" == *".claude.json" ]] && { echo "myserver"; return 0; }
    command jq "$@"
  }
  bats_mock jq
  statusline_run
  [[ "$(bats_strip_ansi "$output")" == *"myserver"* ]]
}

@test "renders nothing when mcpServers is empty" {
  jq() {
    local lastArg="${*[-1]}"
    [[ "$lastArg" == *".claude.json" ]] && return 0
    command jq "$@"
  }
  bats_mock jq
  statusline_run
  [ "$status" -eq 0 ]
  [[ "$(bats_strip_ansi "$output")" != *"⬡"* ]]
}
