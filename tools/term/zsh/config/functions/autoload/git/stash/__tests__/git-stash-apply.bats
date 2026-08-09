bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls git stash pop without args by default" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  bats_mock git

  bats_run_zsh "git-stash-apply"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/git-calls.txt")" == "stash pop" ]]
}

@test "passes stash selector to git stash pop" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  bats_mock git

  bats_run_zsh "git-stash-apply stash@{2}"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/git-calls.txt")" == "stash pop stash@{2}" ]]
}
