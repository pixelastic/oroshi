bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
}

teardown() {
  bats_cleanup
}

@test "removes the worktree directory" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
}

@test "deletes the branch" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  run bats_git branch --list feature
  [ "$output" = "" ]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  # Uses subshell + echo "$PWD" — only way bats can observe a cd side-effect
  bats_run_zsh "cd '${BATS_GIT_WORKTREES}my-repo--feature' && git-worktree-delete feature && echo \"\$PWD\""
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}

@test "blocks deletion if branch has commits ahead of main" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
  [[ "$output" == *"unmerged"* ]]
}

@test "--force bypasses the unmerged commits check" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature --force"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
}

@test "-f bypasses the unmerged commits check" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature -f"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
}

@test "defaults to current branch when called with no argument from inside a worktree" {
  bats_run_zsh "cd '${BATS_GIT_WORKTREES}my-repo--feature' && git-worktree-delete && echo \"\$PWD\""
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}

@test "returns 1 if worktree does not exist" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete nonexistent/branch"
  [ "$status" -eq 1 ]
}

@test "removes multiple worktrees" {
  bats_git_worktree 'feat/thing'
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feat-thing" ]
}

@test "deletes multiple branches" {
  bats_git_worktree 'feat/thing'
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  run bats_git branch --list feature
  [ "$output" = "" ]
  run bats_git branch --list feat/thing
  [ "$output" = "" ]
}

@test "stops at first failure when one branch has unmerged commits" {
  bats_git_worktree 'feat/thing'
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "unmerged commit"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature feat/thing"
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feat-thing" ]
}

@test "removes associated plans/ directory from branch worktree" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--feature/plans/fix_bug"
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feature/plans/fix_bug" ]
}

@test "succeeds without plans/ directory" {
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [ "$status" -eq 0 ]
}

# ── Ralph guard ───────────────────────────────────────────────────────────────

@test "blocks deletion when ralph session is active" {
  ralph-is-running() { return 0; }
  bats_mock ralph-is-running

  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature"
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
}

@test "--force does not bypass the ralph guard" {
  ralph-is-running() { return 0; }
  bats_mock ralph-is-running
  bats_run_zsh "cd '$BATS_GIT_DIR' && git-worktree-delete feature --force"
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feature" ]
}
