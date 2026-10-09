bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Record the python-test call, one argument per line
  python-test() { printf '%s\n' "$@" > "$BATS_TMP_DIR/calls.txt"; }
  bats_mock python-test
}

@test "calls python-test --token-saving with its arguments" {
  bats_run_zsh "python-test-token-saving a.py b.py"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'--token-saving\na.py\nb.py' ]]
}

@test "calls python-test unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "OROSHI_DISABLE_TOKEN_SAVING=1 python-test-token-saving a.py b.py"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'a.py\nb.py' ]]
}

@test "preserves the exit code of python-test" {
  python-test() { return 3; }
  bats_mock python-test

  bats_run_zsh "python-test-token-saving a.py"
  [[ "$status" -eq 3 ]]
}
