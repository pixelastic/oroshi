bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "does nothing when server is not added" {
  claude-mcp-is-added() { return 1; }
  claude() { echo "claude called"; }
  bats_mock claude-mcp-is-added claude

  bats_run_zsh "claude-mcp-remove foo"
  [ "$status" -eq 0 ]
  [[ "$output" != *"claude called"* ]]
}

@test "calls claude mcp remove --scope user <name> when server is added" {
  claude-mcp-is-added() { return 0; }
  claude() { echo "$*"; }
  bats_mock claude-mcp-is-added claude

  bats_run_zsh "claude-mcp-remove foo"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mcp remove --scope user foo"* ]]
  [[ "$output" == *"Restart Claude"* ]]
}
