bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Record the js-test call, one argument per line
  js-test() { printf '%s\n' "$@" > "$BATS_TMP_DIR/calls.txt"; }
  bats_mock js-test
}

@test "calls js-test --token-saving with its arguments" {
  bats_run_zsh "js-test-token-saving a.js b.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'--token-saving\na.js\nb.js' ]]
}

@test "calls js-test unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "OROSHI_DISABLE_TOKEN_SAVING=1 js-test-token-saving a.js b.js"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'a.js\nb.js' ]]
}

@test "preserves the exit code of js-test" {
  js-test() { return 3; }
  bats_mock js-test

  bats_run_zsh "js-test-token-saving a.js"
  [[ "$status" -eq 3 ]]
}
