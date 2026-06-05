bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-is-ahead"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns 0 when worktree has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "returns 1 when worktree has no commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "accepts a path argument" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
}
