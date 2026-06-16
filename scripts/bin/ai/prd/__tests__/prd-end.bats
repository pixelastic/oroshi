bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "prdPath contains plans/<slug>/PRD.md" {
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/repo"; }
  git-branch-current() { echo "feature/my-feature"; }
  git-branch-slug() { echo "my-feature"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current git-branch-slug

  bats_run_zsh "prd-end"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"prdPath":"/repo/plans/my-feature/PRD.md"'* ]]
}

@test "prdPath does not reference ralph/" {
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/repo"; }
  git-branch-current() { echo "feature/my-feature"; }
  git-branch-slug() { echo "my-feature"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current git-branch-slug

  bats_run_zsh "prd-end"
  [ "$status" -eq 0 ]
  [[ "$output" != *"/ralph/"* ]]
}

@test "exits 1 when not in worktree and no branch given" {
  git-directory-is-worktree() { return 1; }
  bats_mock git-directory-is-worktree

  bats_run_zsh "prd-end"
  [ "$status" -eq 1 ]
  [[ "$output" == *"branch name required"* ]]
}

@test "outputs worktreePath and branch fields" {
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/repo"; }
  git-branch-current() { echo "main"; }
  git-branch-slug() { echo "main"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current git-branch-slug

  bats_run_zsh "prd-end"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"worktreePath":"/repo"'* ]]
  [[ "$output" == *'"branch":"main"'* ]]
}
