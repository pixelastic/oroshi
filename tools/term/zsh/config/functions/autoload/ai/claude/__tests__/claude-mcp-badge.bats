bats_load_library 'helper'

setup() {
  bats_tmp_dir

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[text]=15
    COLORS[claude-mcp]=6
  }

  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[claude-mcp-claude_ai_Slack]="slack"
    ICONS[claude-mcp-context7]="c7"
  }
  bats_mock colors-load-definitions icons-load-definitions
}

@test "shows a server with an alias under its alias, colored with the claude-mcp color" {
  claude-transcript-mcp-list-raw() { echo "claude_ai_Slack"; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;6mslack\e[0m' ]]
}

@test "shows a server without an alias under its raw name" {
  claude-transcript-mcp-list-raw() { echo "some_server"; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'\e[38;5;6msome_server\e[0m' ]]
}

@test "joins several connected servers with spaces" {
  claude-transcript-mcp-list-raw() { print -l claude_ai_Slack context7 some_server; }
  bats_mock claude-transcript-mcp-list-raw

  bats_run_zsh "claude-mcp-badge transcript.jsonl"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == "slack c7 some_server" ]]
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

@test "prints nothing and no error when the transcript is missing" {
  bats_run_zsh "claude-mcp-badge $BATS_TMP_DIR/missing.jsonl 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints nothing and no error when the transcript has invalid JSON lines only" {
  echo 'deferred_tools_delta {not json' >"$BATS_TMP_DIR/transcript.jsonl"

  bats_run_zsh "claude-mcp-badge $BATS_TMP_DIR/transcript.jsonl 2>&1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
