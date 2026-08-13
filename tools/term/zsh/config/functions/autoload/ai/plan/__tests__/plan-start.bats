bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "outputs worktreePath, branch and planDir" {
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/repo"; }
  git-branch-current() { echo "feature/my-feature"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current

  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]
  expect_json '.worktreePath' '/repo'
  expect_json '.branch' 'feature/my-feature'
  expect_json '.planDir' '/repo/plans/feature_my-feature/'
  expect_json 'keys | length' '3'
}

@test "exits 1 when not in worktree and no branch given" {
  git-directory-is-worktree() { return 1; }
  bats_mock git-directory-is-worktree

  bats_run_zsh "plan-start"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"branch name required"* ]]
}
