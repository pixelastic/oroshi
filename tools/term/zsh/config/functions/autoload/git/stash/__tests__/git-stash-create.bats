bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls git stash push with message" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  bats_mock git

  bats_run_zsh "git-stash-create 'WIP fix'"
  [[ "$status" -eq 0 ]]
  local call="$(cat "$BATS_TMP_DIR/git-calls.txt")"
  [[ "$call" == *"stash push"* ]]
  [[ "$call" == *"--include-untracked"* ]]
  [[ "$call" == *"--message"* ]]
  [[ "$call" == *"WIP fix"* ]]
}

@test "calls git stash push without message when none given" {
  git() { echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"; }
  bats_mock git

  bats_run_zsh "git-stash-create"
  [[ "$status" -eq 0 ]]
  local call="$(cat "$BATS_TMP_DIR/git-calls.txt")"
  [[ "$call" == *"stash push"* ]]
  [[ "$call" == *"--include-untracked"* ]]
  [[ "$call" != *"--message"* ]]
}
