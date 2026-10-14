bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir "$BATS_TMP_DIR/plan"

  # Focused window 42 runs claude, and the plan directory is a temp dir
  kitty-window-id() { echo "42"; }
  kitty-window-process() { echo "claude"; }
  plan-directory() { echo "$BATS_TMP_DIR/plan"; }
  ralph-mode-toggle() { echo "$*" >"$BATS_TMP_DIR/toggle-args"; }
  bats_mock kitty-window-id kitty-window-process plan-directory ralph-mode-toggle
}

@test "toggles the mode when the focused window runs claude and ralph.json exists" {
  echo '{"mode":"single"}' >"$BATS_TMP_DIR/plan/ralph.json"

  bats_run_zsh "kitty-ralph-mode-toggle"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/toggle-args")" == "$BATS_TMP_DIR/plan" ]]
}

@test "does nothing when the focused window does not run claude" {
  echo '{"mode":"single"}' >"$BATS_TMP_DIR/plan/ralph.json"
  kitty-window-process() { echo "zsh"; }
  bats_mock kitty-window-process

  bats_run_zsh "kitty-ralph-mode-toggle"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/toggle-args" ]]
}

@test "does nothing when the focused window has no process" {
  echo '{"mode":"single"}' >"$BATS_TMP_DIR/plan/ralph.json"
  kitty-window-process() { return 1; }
  bats_mock kitty-window-process

  bats_run_zsh "kitty-ralph-mode-toggle"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/toggle-args" ]]
}

@test "does nothing when no plan directory exists" {
  plan-directory() { return 1; }
  bats_mock plan-directory

  bats_run_zsh "kitty-ralph-mode-toggle"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/toggle-args" ]]
}

@test "does nothing when no ralph.json exists" {
  bats_run_zsh "kitty-ralph-mode-toggle"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/toggle-args" ]]
}
