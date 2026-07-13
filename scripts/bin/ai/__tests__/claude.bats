bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock OROSHI_ROOT with a fake claude binary
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
  mkdir -p "$BATS_TMP_DIR/oroshi/node_modules/.bin"
  printf '#!/bin/zsh\nexit 0\n' > "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
  chmod +x "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  # Mock collaborators as no-ops by default
  kitty-tab-attention-remove() { :; }
  claude-terminal-fix() { :; }
  bats_mock kitty-tab-attention-remove claude-terminal-fix
}

@test "runs claude binary from OROSHI_ROOT node_modules" {
  printf '#!/bin/zsh\ntouch "$BATS_TMP_DIR/binary-called"\n' > "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
  chmod +x "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/binary-called" ]]
}

@test "calls kitty-tab-attention-remove after exit" {
  kitty-tab-attention-remove() { touch "$BATS_TMP_DIR/remove-called"; }
  bats_mock kitty-tab-attention-remove

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/remove-called" ]]
}

@test "calls claude-terminal-fix by default" {
  claude-terminal-fix() { touch "$BATS_TMP_DIR/fix-called"; }
  bats_mock claude-terminal-fix

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/fix-called" ]]
}

@test "skips claude-terminal-fix when CLAUDE_DO_NOT_FIX_TERMINAL_ISSUE_38761 is set" {
  claude-terminal-fix() { touch "$BATS_TMP_DIR/fix-called"; }
  bats_mock claude-terminal-fix
  bats_mock_env CLAUDE_DO_NOT_FIX_TERMINAL_ISSUE_38761 "1"

  bats_run_zsh "claude"

  [[ ! -f "$BATS_TMP_DIR/fix-called" ]]
}
