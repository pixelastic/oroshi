bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-worktree-start"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns base commit hash when worktree has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local baseCommit="$(git rev-parse HEAD)"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$baseCommit" ]
}

@test "accepts a path argument" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local baseCommit="$(git rev-parse HEAD)"
  git commit --allow-empty -m "commit in worktree"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "$baseCommit" ]
}

@test "fails when worktree has no commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -ne 0 ]
}
