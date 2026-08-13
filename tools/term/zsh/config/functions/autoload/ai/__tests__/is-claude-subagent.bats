bats_load_library 'helper'

@test "exits 0 when CLAUDE_IS_SUBAGENT=1" {
  bats_mock_env CLAUDE_IS_SUBAGENT "1"

  bats_run_zsh "is-claude-subagent"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits 1 when CLAUDE_IS_SUBAGENT is unset" {
  bats_run_zsh "unset CLAUDE_IS_SUBAGENT && is-claude-subagent"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "exits 1 when CLAUDE_IS_SUBAGENT is something else" {
  bats_mock_env CLAUDE_IS_SUBAGENT "0"

  bats_run_zsh "is-claude-subagent"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}
