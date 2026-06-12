bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-worktree-path"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "prints the worktree path for a given branch" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "returns 1 if branch has no worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "works from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}
