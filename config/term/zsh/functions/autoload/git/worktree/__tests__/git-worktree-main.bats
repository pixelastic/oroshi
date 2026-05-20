bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns Git Repo Main path from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns own path when called from the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns 1 outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_function git-worktree-main
  [ "$status" -eq 1 ]
}
