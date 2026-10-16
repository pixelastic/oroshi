bats_load_library 'helper'

setup() {
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/input.zsh'"
}

# inputRead

@test "inputRead returns the whole hook JSON from stdin" {
  bats_run_zsh "${sourcePrefix}; inputRead" <<<'{"tool_name":"Bash","cwd":"/tmp"}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = '{"tool_name":"Bash","cwd":"/tmp"}' ]]
}

# inputField

@test "inputField extracts command from a Bash input" {
  bats_run_zsh "${sourcePrefix}; inputField '{\"tool_input\":{\"command\":\"echo hello\"}}' '.tool_input.command'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "echo hello" ]]
}

@test "inputField returns an empty string for a missing field" {
  bats_run_zsh "${sourcePrefix}; inputField '{\"tool_input\":{}}' '.tool_input.command'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# inputSessionExport

@test "inputSessionExport sets CLAUDE_SESSION_ID from session_id" {
  bats_run_zsh "${sourcePrefix}; inputSessionExport '{\"session_id\":\"abc-123\"}'; print -r -- \"\$CLAUDE_SESSION_ID\""
  [[ "$status" -eq 0 ]]
  [[ "$output" = "abc-123" ]]
}

@test "inputSessionExport leaves CLAUDE_SESSION_ID empty without session_id" {
  bats_run_zsh "${sourcePrefix}; inputSessionExport '{\"cwd\":\"/tmp\"}'; print -r -- \"[\$CLAUDE_SESSION_ID]\""
  [[ "$status" -eq 0 ]]
  [[ "$output" = "[]" ]]
}

@test "inputSessionExport exports the variable to child processes" {
  bats_run_zsh "${sourcePrefix}; inputSessionExport '{\"session_id\":\"abc-123\"}'; zsh -c 'print -r -- \"\$CLAUDE_SESSION_ID\"'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "abc-123" ]]
}
