bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls claude-mcp-remove when server is currently added" {
  claude-mcp-is-added() { return 0; }
  claude-mcp-remove() { echo "remove $*"; }
  claude-mcp-add() { echo "add $*"; }
  bats_mock claude-mcp-is-added claude-mcp-remove claude-mcp-add

  bats_run_zsh "claude-mcp-toggle foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"remove foo"* ]]
}

@test "calls claude-mcp-add when server is not currently added" {
  claude-mcp-is-added() { return 1; }
  claude-mcp-remove() { echo "remove $*"; }
  claude-mcp-add() { echo "add $*"; }
  bats_mock claude-mcp-is-added claude-mcp-remove claude-mcp-add

  bats_run_zsh "claude-mcp-toggle foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"add foo"* ]]
}
