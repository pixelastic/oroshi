bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Record the zsh-test call, one argument per line
  zsh-test() { printf '%s\n' "$@" > "$BATS_TMP_DIR/calls.txt"; }
  bats_mock zsh-test
}

@test "calls zsh-test --token-saving with its arguments" {
  bats_run_zsh "zsh-test-token-saving a.bats b.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'--token-saving\na.bats\nb.bats' ]]
}

@test "calls zsh-test unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "OROSHI_DISABLE_TOKEN_SAVING=1 zsh-test-token-saving a.bats b.bats"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = $'a.bats\nb.bats' ]]
}

@test "preserves the exit code of zsh-test" {
  zsh-test() { return 3; }
  bats_mock zsh-test

  bats_run_zsh "zsh-test-token-saving a.bats"
  [[ "$status" -eq 3 ]]
}
