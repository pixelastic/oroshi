bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "cds into the worktree directory" {
  cd "$BATS_GIT_DIR"
  run zsh -c 'git-worktree-switch fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "cds to Git Repo Main when argument is 'main'" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c 'git-worktree-switch main && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-switch nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "returns 1 if called with no arguments" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-switch
  [ "$status" -eq 1 ]
}
