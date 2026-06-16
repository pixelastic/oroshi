bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns 0 when worktree is behind main" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit"
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-is-behind"
  [ "$status" -eq 0 ]
}

@test "returns 1 when worktree is not behind main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-is-behind"
  [ "$status" -eq 1 ]
}

@test "accepts a path argument" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit"
  bats_run_zsh "git-worktree-is-behind ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [ "$status" -eq 0 ]
}
