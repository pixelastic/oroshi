bats_load_library 'helper'

setup() {
  bats_tmp_dir

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[text]=15
    COLORS[claude-mcp]=6
  }
  bats_mock colors-load-definitions
}

@test "shows a connected server under its raw name, colored with the claude-mcp color" {
  claude-transcript-mcp-list-raw() { echo "claude_ai_Slack"; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;6mclaude_ai_Slack\e[0m' ]]
}

@test "joins several connected servers with spaces" {
  claude-transcript-mcp-list-raw() { print -l claude_ai_Slack context7; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "claude_ai_Slack context7" ]]
}

@test "reads the servers of the given transcript" {
  claude-transcript-mcp-list-raw() { echo "$1" >"$BATS_TMP_DIR/arg"; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge /some/transcript.jsonl"
  [[ "$(cat "$BATS_TMP_DIR/arg")" == "/some/transcript.jsonl" ]]
}

@test "prints nothing when no server is connected" {
  claude-transcript-mcp-list-raw() { :; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
