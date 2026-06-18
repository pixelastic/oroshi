bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env HOME "$BATS_TMP_DIR"
}

@test "exits 0 when server key is present in ~/.claude.json" {
  echo '{"mcpServers":{"foo":{}}}' > "$BATS_TMP_DIR/.claude.json"
  bats_run_zsh "claude-mcp-is-added foo"
  [ "$status" -eq 0 ]
}

@test "exits 1 when server key is absent from ~/.claude.json" {
  echo '{"mcpServers":{}}' > "$BATS_TMP_DIR/.claude.json"
  bats_run_zsh "claude-mcp-is-added foo"
  [ "$status" -eq 1 ]
}
