bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Record the argument count and the arguments, so an empty argument stays visible
  mic2txt-autocorrect-add() { echo "$#|$1|$2" >"$BATS_TMP_DIR/add-args"; }
  bats_mock mic2txt-autocorrect-add
}

@test "enter: runs autocorrect-add with both values" {
  bats_run_zsh "printf 'eovim\nNeoVim\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/add-args")" == "2|eovim|NeoVim" ]]
}

@test "empty wrong word: runs nothing" {
  bats_run_zsh "printf '\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "empty replacement: runs autocorrect-add as a suppression rule" {
  bats_run_zsh "printf 'euh\n\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/add-args")" == "2|euh|" ]]
}

@test "backspace: removes the last typed character" {
  bats_run_zsh "printf 'eovimx\177\nNeoVim\n' | popup-autocorrect"

  [[ "$(cat "$BATS_TMP_DIR/add-args")" == "2|eovim|NeoVim" ]]
}

@test "escape in first field: runs nothing" {
  bats_run_zsh "printf 'eov\033\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "escape in second field: runs nothing" {
  bats_run_zsh "printf 'eovim\nNeo\033\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "ctrl-c in first field: runs nothing" {
  bats_run_zsh "printf 'eov\003\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "ctrl-c in second field: runs nothing" {
  bats_run_zsh "printf 'eovim\nNeo\003\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "ctrl-d in first field: runs nothing" {
  bats_run_zsh "printf 'eov\004\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "ctrl-d in second field: runs nothing" {
  bats_run_zsh "printf 'eovim\nNeo\004\n' | popup-autocorrect"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/add-args" ]]
}

@test "failure: reports the error and waits for a key when autocorrect-add fails" {
  mic2txt-autocorrect-add() {
    echo "boom" >&2
    return 1
  }
  bats_mock mic2txt-autocorrect-add

  bats_run_zsh "printf 'eovim\nNeoVim\nx' | popup-autocorrect 2>&1"

  [[ "$status" -ne 0 ]]
  [[ "$output" == *"boom"* ]]
  [[ "$output" == *"Press any key"* ]]
}
