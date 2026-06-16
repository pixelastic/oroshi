bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns Git Repo Main path from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-main"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns own path when called from the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-main"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns 1 outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-worktree-main"
  [ "$status" -eq 1 ]
}

@test "accepts a worktree path argument and returns Main path" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-worktree-main ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "accepts a main repo path argument and returns its own path" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-worktree-main $BATS_GIT_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns 1 when argument path is outside any git repo" {
  bats_run_zsh "git-worktree-main $BATS_TMP_DIR"
  [ "$status" -eq 1 ]
}

@test "accepts a file path inside a worktree and returns Main path" {
  local testFile="${BATS_GIT_WORKTREES}my-repo--fix-bug/somefile.txt"
  touch "$testFile"
  bats_run_zsh "git-worktree-main $testFile"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}
