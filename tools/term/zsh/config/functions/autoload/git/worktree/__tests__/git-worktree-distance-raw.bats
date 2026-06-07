bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-distance-raw"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "outputs 0▮0 for branch with no divergence from main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT" "fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮0" ]
}

@test "outputs correct ahead count when branch has commits not in main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  bats_run_zsh "$CURRENT" "fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "2▮0" ]
}

@test "outputs correct behind count when main has commits not in branch" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT" "fix/bug"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮3" ]
}

@test "exits 1 when called outside a git repo" {
  cd /tmp
  bats_run_zsh "$CURRENT" "fix/bug"
  [ "$status" -eq 1 ]
}

@test "exits 1 when branch is unknown" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "no-such-branch"
  [ "$status" -eq 1 ]
}
