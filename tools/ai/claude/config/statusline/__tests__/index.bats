bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"

  NBSP=$'\u00a0'

  INDEX="${OROSHI_ROOT}/tools/ai/claude/config/statusline/index.zsh"

  # Stub every external helper of main.zsh so the output only depends on the JSON input
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
  claude-mcp-badge() { echo ""; }
  bats_mock colors-load-definitions context-badge icons-load-definitions plan-directory plan-badge ralph-mode claude-mcp-badge
}

@test "renders the statusline from the Claude Code JSON" {
  cat >"${BATS_TMP_DIR}/input.json" <<EOF
{
  "workspace": { "current_dir": "/some/dir" },
  "model": { "display_name": "test" },
  "cost": { "total_cost_usd": 0.05 },
  "context_window": {
    "current_usage": {
      "input_tokens": 51000,
      "output_tokens": 0,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    },
    "used_percentage": 0
  },
  "session_id": "abc-123"
}
EOF
  bats_run_zsh "${INDEX} < '${BATS_TMP_DIR}/input.json'"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "BADGE${NBSP}51k${NBSP}5¢${NBSP}test" ]]
}

@test "sources the main.zsh of the current OROSHI_ROOT" {
  local fakeRoot="${BATS_TMP_DIR}/oroshi"
  local fakeDir="${fakeRoot}/tools/ai/claude/config/statusline"
  mkdir -p "$fakeDir"
  echo 'print "fake main from $OROSHI_ROOT"' >"${fakeDir}/main.zsh"

  # zshenv resets OROSHI_ROOT in child shells, so override it after startup and source the entry point
  bats_run_zsh "OROSHI_ROOT='${fakeRoot}'; source '${INDEX}'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "fake main from ${fakeRoot}" ]]
}

@test "supports --dry-run" {
  bats_run_zsh "${INDEX} --dry-run"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "BADGE${NBSP}51k${NBSP}0¢${NBSP}Sonnet 4.6" ]]
}
