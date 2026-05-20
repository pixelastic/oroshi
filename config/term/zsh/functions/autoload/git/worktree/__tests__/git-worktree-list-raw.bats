bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/dark-mode'
}

teardown() {
  bats_cleanup
}

@test "lists worktrees with branch and path on each line" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list-raw
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮${BATS_GIT_WORKTREES}feat-dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮${BATS_GIT_WORKTREES}fix-bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list-raw
  for line in "${lines[@]}"; do
    [[ "$line" != *"$BATS_GIT_DIR "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}
