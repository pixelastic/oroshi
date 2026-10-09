bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Record the go-test call, one argument per line
  go-test() { printf '%s\n' "$@" > "$BATS_TMP_DIR/calls.txt"; }
  bats_mock go-test
}

@test "calls go-test --token-saving with its arguments" {
  bats_run_zsh "go-test-token-saving a.go b.go"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'--token-saving\na.go\nb.go' ]]
}

@test "calls go-test unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "OROSHI_DISABLE_TOKEN_SAVING=1 go-test-token-saving a.go b.go"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'a.go\nb.go' ]]
}

@test "preserves the exit code of go-test" {
  go-test() { return 3; }
  bats_mock go-test

  bats_run_zsh "go-test-token-saving a.go"
  [[ "$status" -eq 3 ]]
}
