bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "formats raw output into colored table" {
  git-stash-list-raw() { echo "stash@{0}▮WIP on main▮2 hours ago"; }
  git-stash-colorize() { echo "colored-$1"; }
  table() { echo "$1"; }
  bats_mock git-stash-list-raw git-stash-colorize table

  bats_run_zsh "git-stash-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"colored-stash@{0}"* ]]
  [[ "$output" == *"colored-WIP on main"* ]]
  [[ "$output" == *"colored-2 hours ago"* ]]
}

@test "returns nothing when no stashes" {
  git-stash-list-raw() { return 0; }
  bats_mock git-stash-list-raw

  bats_run_zsh "git-stash-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
