bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Record the arguments of each skills-allowlist-add call (skala is an alias of it)
  skills-allowlist-add() { echo "$*" >"$BATS_TMP_DIR/skala-args"; }
  bats_mock skills-allowlist-add
}

@test "enter: runs skala with the typed value" {
  bats_run_zsh "printf 'ls -la\n' | popup-skala"

  [[ "$(cat "$BATS_TMP_DIR/skala-args")" == "ls -la" ]]
}

@test "empty: runs nothing when the field is empty" {
  bats_run_zsh "printf '\n' | popup-skala"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/skala-args" ]]
}

@test "escape: runs nothing" {
  bats_run_zsh "printf 'ls\033\n' | popup-skala"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/skala-args" ]]
}

@test "ctrl-c: runs nothing" {
  bats_run_zsh "printf 'ls\003\n' | popup-skala"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/skala-args" ]]
}

@test "ctrl-d: runs nothing" {
  bats_run_zsh "printf 'ls\004\n' | popup-skala"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/skala-args" ]]
}

@test "success: exits successfully after a successful run" {
  bats_run_zsh "printf 'ls\n' | popup-skala"

  [[ "$status" -eq 0 ]]
}

@test "backspace: removes the last typed character" {
  bats_run_zsh "printf 'lsx\177\n' | popup-skala"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/skala-args")" == "ls" ]]
}

@test "failure: reports the error and waits for a key when skala fails" {
  skills-allowlist-add() {
    echo "boom" >&2
    return 1
  }
  bats_mock skills-allowlist-add

  bats_run_zsh "printf 'ls\nx' | popup-skala 2>&1"

  [[ "$status" -ne 0 ]]
  [[ "$output" == *"boom"* ]]
  [[ "$output" == *"Press any key"* ]]
}
