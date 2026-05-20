bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/thing'
}

teardown() {
  bats_cleanup
}

@test "does not include 'main'" {
  cd "$BATS_GIT_DIR"
  bats_run_function complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [[ "$output" != *"main"* ]]
}

@test "includes linked worktree branch names" {
  cd "$BATS_GIT_DIR"
  bats_run_function complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/thing"* ]]
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_function complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
