bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "prints branch name inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function git-worktree-name
  [ "$status" -eq 0 ]
  [ "$output" = "fix/bug" ]
}

@test "prints nothing in the main repo" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-name
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "prints nothing outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_function git-worktree-name
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "accepts an explicit path to a linked worktree" {
  bats_run_function git-worktree-name "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "fix/bug" ]
}

@test "accepts an explicit path to the main repo" {
  bats_run_function git-worktree-name "$BATS_GIT_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
