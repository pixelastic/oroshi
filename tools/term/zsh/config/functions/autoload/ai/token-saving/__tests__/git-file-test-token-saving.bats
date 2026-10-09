bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Record the git-file-test call, one argument per line
  git-file-test() { printf '%s\n' "$@" > "$BATS_TMP_DIR/calls.txt"; }
  bats_mock git-file-test
}

@test "calls git-file-test --token-saving" {
  bats_run_zsh "git-file-test-token-saving"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = '--token-saving' ]]
}

@test "calls git-file-test unchanged when OROSHI_DISABLE_TOKEN_SAVING=1" {
  bats_run_zsh "OROSHI_DISABLE_TOKEN_SAVING=1 git-file-test-token-saving"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls.txt")" = '' ]]
}

@test "preserves the exit code of git-file-test" {
  git-file-test() { return 3; }
  bats_mock git-file-test

  bats_run_zsh "git-file-test-token-saving"
  [[ "$status" -eq 3 ]]
}
