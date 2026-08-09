bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs ▮-separated fields: index, message, date" {
  git() {
    [[ "$1" == "stash" ]] && echo "stash@{0}▮WIP on main▮2 hours ago"
  }
  bats_mock git

  bats_run_zsh "git-stash-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "stash@{0}▮WIP on main▮2 hours ago" ]]
}

@test "handles multiple stashes" {
  git() {
    [[ "$1" == "stash" ]] && printf 'stash@{0}▮WIP on main▮2 hours ago\nstash@{1}▮fix bug▮3 days ago\n'
  }
  bats_mock git

  bats_run_zsh "git-stash-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "stash@{0}▮WIP on main▮2 hours ago" ]]
  [[ "${lines[1]}" == "stash@{1}▮fix bug▮3 days ago" ]]
}

@test "returns nothing when no stashes" {
  git() { return 0; }
  bats_mock git

  bats_run_zsh "git-stash-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
