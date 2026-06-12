bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-directory-is-worktree"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns 0 inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "returns 1 in the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "returns 1 outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "accepts an explicit path argument" {
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
}
