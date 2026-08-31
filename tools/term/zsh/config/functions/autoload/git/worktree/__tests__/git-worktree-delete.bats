bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  export OROSHI_WORKTREE_ARCHIVES_DIR="$BATS_TMP_DIR/worktrees/_ARCHIVES"
}

@test "removes the worktree directory" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

@test "deletes the branch" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  run bats_git branch --list feature
  [[ "$output" = "" ]]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  # Uses subshell + echo "$PWD" — only way bats can observe a cd side-effect
  bats_run_zsh "cd '${BATS_GIT_WORKTREES}my-repo--feature' && git-worktree-delete feature && echo \"\$PWD\""
  [[ "$status" -eq 0 ]]
  [[ "${lines[-1]}" = "$BATS_GIT_DIR" ]]
}

@test "blocks deletion if branch has commits ahead of main" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 1 ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ "$output" == *"unmerged"* ]]
}

@test "--force bypasses the unmerged commits check" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature --force"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

@test "-f bypasses the unmerged commits check" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature -f"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

@test "defaults to current branch when called with no argument from inside a worktree" {
  bats_run_zsh "cd '${BATS_GIT_WORKTREES}my-repo--feature' && git-worktree-delete && echo \"\$PWD\""
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ "${lines[-1]}" = "$BATS_GIT_DIR" ]]
}

@test "returns 1 if worktree does not exist" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete nonexistent/branch"
  [[ "$status" -eq 1 ]]
}

@test "removes multiple worktrees" {
  bats_git_worktree 'feat/thing'
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feat-thing" ]]
}

@test "deletes multiple branches" {
  bats_git_worktree 'feat/thing'
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  run bats_git branch --list feature
  [[ "$output" = "" ]]
  run bats_git branch --list feat/thing
  [[ "$output" = "" ]]
}

@test "stops at first failure when one branch has unmerged commits" {
  bats_git_worktree 'feat/thing'
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  [[ "$status" -eq 1 ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--feat-thing" ]]
}

@test "succeeds when worktree has no plan" {
  plan-directory() { return 1; }
  bats_mock plan-directory
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 0 ]]
}

# ── Ralph guard ───────────────────────────────────────────────────────────────

@test "blocks deletion when ralph session is active in external plan dir" {
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"; }
  ralph-is-running() { return 0; }
  bats_mock plan-directory ralph-is-running
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 1 ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

@test "--force does not bypass the ralph guard" {
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/my-repo--feature"; }
  ralph-is-running() { return 0; }
  bats_mock plan-directory ralph-is-running
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature --force"
  [[ "$status" -eq 1 ]]
  [[ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

# ── Claude guard ─────────────────────────────────────────────────────────────

@test "stops Claude sessions before deleting worktree" {
  claude-stop-in() { echo "$@" > "$BATS_TMP_DIR/claude-stop-in-args.txt"; }
  bats_mock claude-stop-in
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
  [[ "$(cat "$BATS_TMP_DIR/claude-stop-in-args.txt")" == "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}

@test "deletes worktree even when no Claude session is running" {
  claude-stop-in() { return 0; }
  bats_mock claude-stop-in
  bats_disable_worktree_aware

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [[ "$status" -eq 0 ]]
  [[ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]]
}
