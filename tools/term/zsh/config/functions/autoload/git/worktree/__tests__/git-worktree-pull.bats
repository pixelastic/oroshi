bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

@test "rebases worktree on top of main" {
  git -C "$BATS_GIT_DIR" commit --allow-empty --quiet -m "main work"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-pull"
  [[ "$status" -eq 0 ]]
  run git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" log --oneline
  [[ "$output" == *"main work"* ]]
}

@test "calls git-dependencies-update with pre-rebase commit" {
  git-dependencies-update() { echo "$@" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  git -C "$BATS_GIT_DIR" commit --allow-empty --quiet -m "main work"
  local preRebaseCommit="$(git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" rev-parse HEAD)"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-pull"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "$preRebaseCommit --async" ]]
}

@test "does not call git-dependencies-update when rebase fails" {
  git-dependencies-update() { echo "called" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  # Create a conflict on both sides
  echo "main content" > "$BATS_GIT_DIR/conflict.txt"
  git -C "$BATS_GIT_DIR" add conflict.txt
  git -C "$BATS_GIT_DIR" commit --quiet -m "main change"

  echo "bug content" > "${BATS_GIT_WORKTREES}my-repo--fix-bug/conflict.txt"
  git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" add conflict.txt
  git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" commit --quiet -m "bug change"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-pull"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/dep-update-calls" ]]
}

@test "aborts if preflight fails, rebase never happens" {
  git-worktree-submodule-preflight() {
    echo "my-sub has uncommitted changes"
    return 1
  }
  git-dependencies-update() { :; }
  bats_mock git-worktree-submodule-preflight git-dependencies-update
  bats_disable_worktree_aware

  git -C "$BATS_GIT_DIR" commit --allow-empty --quiet -m "main work"
  local headBefore="$(git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" rev-parse HEAD)"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-pull"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"my-sub has uncommitted changes"* ]]

  # HEAD unchanged — rebase never ran
  local headAfter="$(git -C "${BATS_GIT_WORKTREES}my-repo--fix-bug" rev-parse HEAD)"
  [[ "$headBefore" == "$headAfter" ]]
}
