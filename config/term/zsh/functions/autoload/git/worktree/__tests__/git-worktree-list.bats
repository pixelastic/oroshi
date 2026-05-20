bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/dark-mode'
}

teardown() {
  bats_cleanup
}

@test "output contains branch names" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/dark-mode"* ]]
}

@test "output does not contain file paths" {
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [[ "$output" != *"$OROSHI_WORKTREES_DIR"* ]]
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "marks current worktree with pointer" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *""* ]]
}

@test "shows ahead count vs main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "commit one"
  git commit --allow-empty -m "commit two"
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* ]]
}

@test "shows behind count vs main" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"3"* ]]
}

@test "shows relative date of last commit" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "dated commit"
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"seconds"* ]]
}

@test "shows last commit message" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "my test commit"
  cd "$BATS_GIT_DIR"
  bats_run_function git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"my test commit"* ]]
}
