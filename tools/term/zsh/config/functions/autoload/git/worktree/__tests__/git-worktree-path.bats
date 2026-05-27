bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "prints the worktree path for a given branch" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-path fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "returns 1 if branch has no worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-path nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "works from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function git-worktree-path fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}
