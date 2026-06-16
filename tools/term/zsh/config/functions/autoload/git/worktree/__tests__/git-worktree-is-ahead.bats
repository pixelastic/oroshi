bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns 0 when worktree has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  git commit --allow-empty -m "unmerged"
  bats_run_zsh "git-worktree-is-ahead"
  [ "$status" -eq 0 ]
}

@test "returns 1 when worktree has no commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-is-ahead"
  [ "$status" -eq 1 ]
}

@test "accepts a path argument" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  git commit --allow-empty -m "unmerged"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-is-ahead ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [ "$status" -eq 0 ]
}
