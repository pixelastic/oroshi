bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock OROSHI_ROOT with a fake claude binary
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
  mkdir -p "$BATS_TMP_DIR/oroshi/node_modules/.bin"
  printf '#!/bin/zsh\nexit 0\n' > "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
  chmod +x "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  # Mock collaborators by default: no-op cleanup, binary has the patch marker
  kitty-tab-notification-remove() { :; }
  claude-is-color-patched() { return 0; }
  bats_mock kitty-tab-notification-remove claude-is-color-patched
}

@test "runs claude binary from OROSHI_ROOT node_modules" {
  printf '#!/bin/zsh\ntouch "$BATS_TMP_DIR/binary-called"\n' > "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
  chmod +x "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/binary-called" ]]
}

@test "calls kitty-tab-notification-remove after exit" {
  kitty-tab-notification-remove() { touch "$BATS_TMP_DIR/remove-called"; }
  bats_mock kitty-tab-notification-remove

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/remove-called" ]]
}

# --- Syntax patch before launch ---

# Fake generate-syntax that logs its call, and a fake binary that logs its args
_fake_generate_syntax() {
  local exitCode="${1:-0}"
  local syntaxDir="$BATS_TMP_DIR/oroshi/tools/ai/claude/config/patch/syntax"
  mkdir -p "$syntaxDir"
  printf '#!/bin/zsh\necho generate-syntax >> "$BATS_TMP_DIR/calls.txt"\nexit %s\n' "$exitCode" > "$syntaxDir/generate-syntax"
  chmod +x "$syntaxDir/generate-syntax"
}

_fake_binary_logging_calls() {
  printf '#!/bin/zsh\necho "binary $*" >> "$BATS_TMP_DIR/calls.txt"\n' > "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
  chmod +x "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"
}

_mock_unpatched() {
  claude-is-color-patched() { return 1; }
  bats_mock claude-is-color-patched
}

@test "prints the patching notice when the binary has no marker" {
  _mock_unpatched
  _fake_generate_syntax

  bats_run_zsh "claude"

  [[ "$output" == *"Patching Claude Code syntax…"* ]]
}

@test "runs generate-syntax once when the binary has no marker" {
  _mock_unpatched
  _fake_generate_syntax

  bats_run_zsh "claude"

  [[ "$(grep --count generate-syntax "$BATS_TMP_DIR/calls.txt")" -eq 1 ]]
}

@test "launches claude after the patch" {
  _mock_unpatched
  _fake_generate_syntax
  _fake_binary_logging_calls

  bats_run_zsh "claude"

  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == $'generate-syntax\nbinary ' ]]
}

@test "does not run generate-syntax when the binary has the marker" {
  _fake_generate_syntax

  bats_run_zsh "claude"

  [[ ! -f "$BATS_TMP_DIR/calls.txt" ]]
}

@test "does not print the notice when the binary has the marker" {
  _fake_generate_syntax

  bats_run_zsh "claude"

  [[ "$output" != *"Patching"* ]]
}

@test "launches claude when the binary has the marker" {
  _fake_binary_logging_calls

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == "binary " ]]
}

@test "prints the error message when the patch fails" {
  _mock_unpatched
  _fake_generate_syntax 1

  bats_run_zsh "claude"

  [[ "$output" == *"✘ Could not patch Claude Code syntax colors"* ]]
}

@test "still launches claude when the patch fails" {
  _mock_unpatched
  _fake_generate_syntax 1
  _fake_binary_logging_calls

  bats_run_zsh "claude"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" == $'generate-syntax\nbinary ' ]]
}

@test "forwards the arguments to claude when the patch fails" {
  _mock_unpatched
  _fake_generate_syntax 1
  _fake_binary_logging_calls

  bats_run_zsh "claude --resume abc"

  [[ "$(tail -n 1 "$BATS_TMP_DIR/calls.txt")" == "binary --resume abc" ]]
}
