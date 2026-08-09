bats_load_library 'helper'

setup() {
  bats_tmp_dir

  git-directory-is-github() { return 0; }
  git-github-project() { echo "pixelastic/my-repo"; }
  bats_mock git-directory-is-github git-github-project
}

@test "returns issue count from GitHub search API" {
  gh() { echo "7"; }
  bats_mock gh

  bats_run_zsh "git-issue-count"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "7" ]]
}

@test "returns 0 when no open issues" {
  gh() { echo "0"; }
  bats_mock gh

  bats_run_zsh "git-issue-count"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "0" ]]
}

@test "fails when not in a GitHub repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-count"
  [[ "$status" -ne 0 ]]
}
