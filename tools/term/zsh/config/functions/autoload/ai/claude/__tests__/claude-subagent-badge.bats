bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export SESSION_DIR="$CLAUDE_SESSIONS_DIR/abc-123"
  mkdir -p "$SESSION_DIR"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[text]=15
    COLORS[claude-subagentRunning]=2
  }
  bats_mock colors-load-definitions
}

@test "prints one dot per running sub-agent" {
  echo '{"subagents":[{"id":"a1","status":"running"},{"id":"a2","status":"running"}]}' >"$SESSION_DIR/statusline.json"

  bats_run_zsh "claude-subagent-badge abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "●●" ]]
}

@test "colors running dots with the claude-subagentRunning color" {
  echo '{"subagents":[{"id":"a1","status":"running"}]}' >"$SESSION_DIR/statusline.json"

  bats_run_zsh "claude-subagent-badge abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;2m'* ]]
}

@test "prints nothing when statusline.json is missing" {
  bats_run_zsh "claude-subagent-badge abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints nothing when statusline.json is not valid JSON" {
  echo '{"subagents":[' >"$SESSION_DIR/statusline.json"

  bats_run_zsh "claude-subagent-badge abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints nothing when the subagents list is empty" {
  echo '{"subagents":[]}' >"$SESSION_DIR/statusline.json"

  bats_run_zsh "claude-subagent-badge abc-123"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
