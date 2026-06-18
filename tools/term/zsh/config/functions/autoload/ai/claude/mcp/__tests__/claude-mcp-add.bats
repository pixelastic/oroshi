bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "does nothing when server is already added" {
  claude-mcp-is-added() { return 0; }
  claude-mcp-add-foo() { echo "sub-script called"; }
  bats_mock claude-mcp-is-added claude-mcp-add-foo

  bats_run_zsh "claude-mcp-add foo"
  [ "$status" -eq 0 ]
  [[ "$output" != *"sub-script called"* ]]
}

@test "add the server if not already added" {
  claude-mcp-is-added() { return 1; }
  claude-mcp-add-foo() { echo "sub-script called"; }
  bats_mock claude-mcp-is-added claude-mcp-add-foo

  bats_run_zsh "claude-mcp-add foo"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sub-script called"* ]]
}

@test "fails when no such server script exists" {
  claude-mcp-is-added() { return 1; }
  bats_mock claude-mcp-is-added

  bats_run_zsh "claude-mcp-add foo"
  [ "$status" -eq 1 ]
}
