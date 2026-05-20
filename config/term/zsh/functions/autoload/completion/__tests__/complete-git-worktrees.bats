bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  export BATS_MY_REPO="$BATS_GIT_DIR"

  bats_git_dir 'other-repo'
  bats_git_worktree 'feat/x'
}

teardown() {
  bats_cleanup
}

@test "includes worktrees of the current repo" {
  cd "$BATS_MY_REPO"
  bats_run_function complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}

@test "always includes 'main'" {
  cd "$BATS_MY_REPO"
  bats_run_function complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]
}

@test "does not include worktrees from other repos" {
  cd "$BATS_MY_REPO"
  bats_run_function complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" != *"feat/x"* ]]
}

@test "outputs only 'main' when no linked worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_function complete-git-worktrees
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "returns 'main' and succeeds outside a git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_function complete-git-worktrees
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}
