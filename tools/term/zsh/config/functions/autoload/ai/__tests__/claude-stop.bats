bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default: running inside Claude main session
  is-claude() { return 0; }
  is-claude-subagent() { return 1; }
  kill() { echo "$@" > "$BATS_TMP_DIR/kill-args.txt"; }
  bats_mock is-claude is-claude-subagent kill
}

# --- Guard: not in Claude ---

@test "exits 0 silently when not in Claude" {
  is-claude() { return 1; }
  bats_mock is-claude

  bats_run_zsh "claude-stop"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -f "$BATS_TMP_DIR/kill-args.txt" ]]
}

# --- Guard: in subagent ---

@test "exits 0 silently when in a subagent" {
  is-claude-subagent() { return 0; }
  bats_mock is-claude-subagent

  bats_run_zsh "claude-stop"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -f "$BATS_TMP_DIR/kill-args.txt" ]]
}

# --- Kill logic: finds claude in ancestor chain ---

@test "sends SIGTERM to first claude ancestor" {
  process-tree-raw() {
    echo "100▮zsh"
    echo "200▮node"
    echo "300▮claude"
  }
  bats_mock process-tree-raw

  bats_run_zsh "claude-stop"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kill-args.txt")" == "-TERM 300" ]]
}

@test "sends SIGTERM to immediate parent if it is claude" {
  process-tree-raw() {
    echo "50▮claude"
  }
  bats_mock process-tree-raw

  bats_run_zsh "claude-stop"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kill-args.txt")" == "-TERM 50" ]]
}

# --- Kill logic: claude not found ---

@test "exits 1 with error when claude not in ancestor chain" {
  process-tree-raw() {
    echo "100▮zsh"
    echo "200▮node"
  }
  bats_mock process-tree-raw

  bats_run_zsh "claude-stop"

  [[ "$status" -eq 1 ]]
  [[ "$output" == *"claude process not found"* ]]
  [[ ! -f "$BATS_TMP_DIR/kill-args.txt" ]]
}
