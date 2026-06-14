bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-worktree-distance-raw"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "outputs 0▮0 for branch with no divergence from main" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && source $CURRENT fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮0" ]
}

@test "outputs correct ahead count when branch has commits not in main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && source $CURRENT fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "2▮0" ]
}

@test "outputs correct behind count when main has commits not in branch" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && source $CURRENT fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮3" ]
}

@test "exits 1 when called outside a git repo" {
  bats_run_zsh "cd /tmp && source $CURRENT fix/bug"
  [ "$status" -eq 1 ]
}

@test "exits 1 when branch is unknown" {
  bats_run_zsh "cd $BATS_GIT_DIR && source $CURRENT no-such-branch"
  [ "$status" -eq 1 ]
}

@test "auto-detects branch when called without argument" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && source $CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮0" ]
}

@test "exits 1 when called without argument outside a git repo" {
  bats_run_zsh "cd /tmp && source $CURRENT"
  [ "$status" -eq 1 ]
}
