bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug" || return 1
  git commit --allow-empty --quiet -m "fix work"
}

@test "fast-forwards main to current HEAD" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local fixHead="$(git rev-parse HEAD)"
  bats_run_zsh "git-worktree-push"
  [[ "$status" -eq 0 ]]
  run bats_git rev-parse main
  [[ "$output" = "$fixHead" ]]
}

@test "calls git-dependencies-update with --repo mainPath and pre-merge HEAD" {
  git-dependencies-update() { echo "$@" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local mainPath="$BATS_GIT_DIR"
  local preMergeHead="$(git -C "$mainPath" rev-parse HEAD)"
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "--repo $mainPath $preMergeHead" ]]
}

@test "returns 1 if history has diverged" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main work"
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-push"
  [[ "$status" -ne 0 ]]
}
