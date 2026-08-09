bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs index:message for each stash" {
  git-stash-list-raw() {
    printf 'stash@{0}▮WIP on main▮2 hours ago\nstash@{1}▮fix bug▮3 days ago\n'
  }
  bats_mock git-stash-list-raw

  bats_run_zsh "complete-git-stash"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "stash@{0}:WIP on main" ]]
  [[ "${lines[1]}" == "stash@{1}:fix bug" ]]
}

@test "returns nothing when no stashes" {
  git-stash-list-raw() { return 0; }
  bats_mock git-stash-list-raw

  bats_run_zsh "complete-git-stash"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
