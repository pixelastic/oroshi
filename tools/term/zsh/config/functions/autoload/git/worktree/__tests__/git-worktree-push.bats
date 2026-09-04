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
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "--repo $mainPath $preMergeHead --async" ]]
}

@test "returns 1 if history has diverged" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main work"
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-push"
  [[ "$status" -ne 0 ]]
}

@test "aborts if preflight fails, merge never happens" {
  git-worktree-submodule-preflight() {
    echo "my-sub has uncommitted changes"
    return 1
  }
  git-dependencies-update() { :; }
  bats_mock git-worktree-submodule-preflight git-dependencies-update
  bats_disable_worktree_aware

  local mainHeadBefore="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -ne 0 ]]
  [[ "$output" != "" ]]

  # Main HEAD unchanged — merge never ran
  local mainHeadAfter="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
  [[ "$mainHeadBefore" == "$mainHeadAfter" ]]
}

@test "pushes changed submodule to remote before merge" {
  # Fresh repo with submodule + worktree
  bats_git_dir 'sub-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
  local worktree="${BATS_GIT_WORKTREES}sub-repo--fix-bug"

  # Advance submodule pointer in worktree so it differs from main
  local upstream="$BATS_TMP_DIR/sub-upstream-my-sub"
  git -C "$upstream" commit --allow-empty --quiet -m "advance"
  local newHash="$(git -C "$upstream" rev-parse HEAD)"
  git -C "$worktree" update-index --cacheinfo "160000,$newHash,my-sub"
  git -C "$worktree" commit --quiet -m "update sub pointer"

  # Mock collaborators
  git-worktree-submodule-preflight() { return 0; }
  git-branch-push() { echo "$@" >> "$BATS_TMP_DIR/push-calls"; }
  git-dependencies-update() { :; }
  git-submodule-list-raw() { echo "my-sub▮abc12345▮main"; }
  bats_mock git-worktree-submodule-preflight git-branch-push git-dependencies-update git-submodule-list-raw
  bats_disable_worktree_aware

  bats_run_zsh "cd $worktree && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/push-calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/push-calls")" == *"--repo"*"my-sub"* ]]
}

@test "skips submodule push when pointers are identical" {
  # Fresh repo with submodule + worktree (same pointer in both)
  bats_git_dir 'sub-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
  local worktree="${BATS_GIT_WORKTREES}sub-repo--fix-bug"
  git -C "$worktree" commit --allow-empty --quiet -m "fix work"

  # Mock collaborators
  git-worktree-submodule-preflight() { return 0; }
  git-branch-push() { echo "$@" >> "$BATS_TMP_DIR/push-calls"; }
  git-dependencies-update() { :; }
  git-submodule-list-raw() { echo "my-sub▮abc12345▮main"; }
  bats_mock git-worktree-submodule-preflight git-branch-push git-dependencies-update git-submodule-list-raw
  bats_disable_worktree_aware

  local mainHeadBefore="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"

  bats_run_zsh "cd $worktree && git-worktree-push"
  [[ "$status" -eq 0 ]]
  # git-branch-push should NOT have been called
  [[ ! -f "$BATS_TMP_DIR/push-calls" ]]
  # Merge still happened — main HEAD advanced
  local mainHeadAfter="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
  [[ "$mainHeadBefore" != "$mainHeadAfter" ]]
}
