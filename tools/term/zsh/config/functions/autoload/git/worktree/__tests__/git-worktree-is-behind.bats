bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-is-behind"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns 0 when worktree is behind main" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit"
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "returns 1 when worktree is not behind main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "accepts a path argument" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit"
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
}
