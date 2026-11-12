bats_load_library 'helper'

setup() {
  bats_tmp_dir

  SEGMENT="${OROSHI_ROOT}/tools/ai/claude/config/statusline/segments/subagent.zsh"
  EN_SPACE=$' '

  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export SESSION_DIR="$CLAUDE_SESSIONS_DIR/abc-123"
  mkdir -p "$SESSION_DIR"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[text]=15
    COLORS[claude-subagent-running]=2
    COLORS[claude-subagent-pending]=3
    COLORS[claude-subagent-review-code]=11
    COLORS[claude-subagent-review-spec]=12
  }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[claude-subagent]=$'DOT '
  }
  bats_mock colors-load-definitions icons-load-definitions
}

# Run the segment for session abc-123 and print REPLY
run_segment() {
  bats_run_zsh "colors-load-definitions; icons-load-definitions; source '$SEGMENT'; getSubagentSegment abc-123; print -rn -- \$REPLY"
}

@test "colors a running code review sub-agent with the claude-subagent-review-code color" {
  echo '{"subagents":[{"id":"a1","status":"running","description":"Code review"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;11m'* ]]
}

@test "colors a running spec review sub-agent with the claude-subagent-review-spec color" {
  echo '{"subagents":[{"id":"a1","status":"running","description":"Spec review"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;12m'* ]]
}

@test "matches review descriptions by their case-insensitive start" {
  echo '{"subagents":[{"id":"a1","status":"running","description":"code Review axis"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;11m'* ]]
}

@test "colors a pending review sub-agent with the claude-subagent-pending color" {
  echo '{"subagents":[{"id":"a1","status":"pending","description":"Code review"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;3m'* ]]
}

@test "colors a running sub-agent with another description with the claude-subagent-running color" {
  echo '{"subagents":[{"id":"a1","status":"running","description":"Explore the codebase"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;2m'* ]]
}

@test "keeps a U+2002 after each dot" {
  echo '{"subagents":[{"id":"b1","status":"pending"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;3mDOT \e[0m' ]]
}

@test "renders mixed pending and running dots in state file order" {
  echo '{"subagents":[{"id":"a1","status":"running"},{"id":"b1","status":"pending"},{"id":"a2","status":"running"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;2mDOT \e[0m\e[38;5;3mDOT \e[0m\e[38;5;2mDOT \e[0m' ]]
}

@test "renders one dot per sub-agent" {
  echo '{"subagents":[{"id":"a1","status":"running"},{"id":"a2","status":"running"}]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "DOT${EN_SPACE}DOT${EN_SPACE}" ]]
}

@test "renders nothing when statusline.json is missing" {
  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "renders nothing when statusline.json is not valid JSON" {
  echo '{"subagents":[' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "renders nothing when the subagents list is empty" {
  echo '{"subagents":[]}' >"$SESSION_DIR/statusline.json"

  run_segment
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
