bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-push"
  bats_git_worktree 'fix/bug'
  cd "${BATS_GIT_WORKTREES}fix-bug" || return 1
  git commit --allow-empty --quiet -m "fix work"
}

teardown() {
  bats_cleanup
}

@test "fast-forwards main to current HEAD" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local fixHead="$(git rev-parse HEAD)"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  run bats_git rev-parse main
  [ "$output" = "$fixHead" ]
}

@test "returns 1 if history has diverged" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main work"
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -ne 0 ]
}
