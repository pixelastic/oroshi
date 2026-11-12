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
    COLORS[ralph-auto]=226
  }
  context-badge() { echo "BADGE"; }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[ralph-auto]="AUTO"
  }
  plan-directory() { echo ""; }
  plan-badge() { echo ""; }
  ralph-mode() { echo ""; }
  claude-subagent-badge() { echo ""; }
  claude-mcp-badge() { echo ""; }
  bats_mock colors-load-definitions context-badge icons-load-definitions plan-directory plan-badge ralph-mode claude-subagent-badge claude-mcp-badge
}

statusline_json() {
  local dir="${1:-/some/dir}"
  local tokens="${2:-0}"
  local cost="${3:-0}"
  local session="${4:-test-session}"
  local contextPercentage="${5:-0}"
  local transcript="${6:-}"
  local transcriptField=""
  [[ "$transcript" != "" ]] && transcriptField="\"transcript_path\": \"$transcript\","
  cat <<EOF
{
  $transcriptField
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
  bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline < '${BATS_TMP_DIR}/input.json'"
}

# Mock claude-mcp-badge: prints "MCP" only for the given transcript path
# Usage: mock_mcp_badge "/some/transcript.jsonl"
mock_mcp_badge() {
  bats_mock_env "MOCK_TRANSCRIPT" "$1"
  claude-mcp-badge() {
    [[ "$1" == "$MOCK_TRANSCRIPT" && "$1" != "" ]] && echo "MCP"
    return 0
  }
  bats_mock claude-mcp-badge
}

@test "renders badge, tokens, cost, and model" {
  statusline_run "/some/dir" 51000 0.05 "abc-123"
  [[ "$status" -eq 0 ]]
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

@test "mcp badge: rendered from the transcript path" {
  mock_mcp_badge "/some/transcript.jsonl"
  statusline_run "/some/dir" 0 0 "x" 0 "/some/transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *"test MCP "* ]]
}

@test "mcp badge: no section when transcript_path is missing" {
  mock_mcp_badge "/some/transcript.jsonl"
  statusline_run "/some/dir" 0 0 "x"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" != *"MCP"* ]]
  [[ "$(bats_strip_ansi "$output")" == "BADGE 0k 0¢ test " ]]
}

@test "mcp badge: never reads ~/.claude.json" {
  mock_mcp_badge "/some/transcript.jsonl"
  jq() {
    [[ "${*[-1]}" == *".claude.json" ]] && echo "$*" >>"$BATS_TMP_DIR/claude-json-reads"
    command jq "$@"
  }
  bats_mock jq
  statusline_run "/some/dir" 0 0 "x" 0 "/some/transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/claude-json-reads" ]]
}

@test "mcp badge: --dry-run renders without a transcript" {
  bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline --dry-run"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "BADGE 51k 0¢ Sonnet 4.6 " ]]
}

@test "plan progress: badge included when plan active" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  bats_mock plan-directory plan-badge
  statusline_run "/some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *"PLAN_BADGE"* ]]
}

@test "plan progress: segment absent when no plan" {
  statusline_run "/some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" != *"PLAN_BADGE"* ]]
}

@test "sub-agent badge: rendered between the model and the mcp badge" {
  mock_mcp_badge "/some/transcript.jsonl"
  claude-subagent-badge() { [[ "$1" == "abc-123" ]] && echo "DOTS"; }
  bats_mock claude-subagent-badge
  statusline_run "/some/dir" 0 0 "abc-123" 0 "/some/transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *"test DOTS MCP " ]]
}

@test "sub-agent badge: no extra segment when the badge is empty" {
  mock_mcp_badge "/some/transcript.jsonl"
  statusline_run "/some/dir" 0 0 "abc-123" 0 "/some/transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *"test MCP " ]]
}

@test "mcp badge: rendered before the plan badge" {
  mock_mcp_badge "/some/transcript.jsonl"
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  bats_mock plan-directory plan-badge
  statusline_run "/some/dir" 0 0 "x" 0 "/some/transcript.jsonl"
  [[ "$(bats_strip_ansi "$output")" == *"MCP PLAN_BADGE "* ]]
}

@test "ralph auto: yellow icon right after the plan badge when mode is auto" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  ralph-mode() { [[ "$1" == "/some/plan/dir" ]] && echo "auto"; }
  bats_mock plan-directory plan-badge ralph-mode
  statusline_run "/some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *"PLAN_BADGE AUTO "* ]]
  [[ "$output" == *$'\e[38;5;226m'"AUTO"* ]]
}

@test "ralph auto: no icon when mode is single" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  ralph-mode() { echo "single"; }
  bats_mock plan-directory plan-badge ralph-mode
  statusline_run "/some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" != *"AUTO"* ]]
}

@test "ralph auto: no icon when ralph.json does not exist" {
  plan-directory() { echo "/some/plan/dir"; }
  plan-badge() { echo "PLAN_BADGE"; }
  bats_mock plan-directory plan-badge
  statusline_run "/some/dir"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" != *"AUTO"* ]]
}
