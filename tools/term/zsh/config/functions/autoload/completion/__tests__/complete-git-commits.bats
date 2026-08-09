bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs shortHash:subject for each commit" {
  git-commit-list-raw() {
    printf 'abc1234▮2 hours ago▮Tim▮add feature\ndef5678▮3 days ago▮Tim▮resolve bug\n'
  }
  bats_mock git-commit-list-raw

  bats_run_zsh "complete-git-commits"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "abc1234:add feature" ]]
  [[ "${lines[1]}" == "def5678:resolve bug" ]]
}

@test "returns nothing when no commits" {
  git-commit-list-raw() { return 0; }
  bats_mock git-commit-list-raw

  bats_run_zsh "complete-git-commits"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
