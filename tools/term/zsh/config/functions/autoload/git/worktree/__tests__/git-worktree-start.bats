bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

@test "returns base commit hash when worktree has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local baseCommit="$(git rev-parse HEAD)"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  bats_run_zsh "git-worktree-start"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$baseCommit" ]]
}

@test "accepts a path argument" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local baseCommit="$(git rev-parse HEAD)"
  git commit --allow-empty -m "commit in worktree"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-start ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$baseCommit" ]]
}

@test "returns base commit after branch is merged into main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local baseCommit="$(git rev-parse HEAD)"
  git commit --allow-empty -m "branch work"

  # Merge the branch into main (simulates post-PR merge)
  cd "$BATS_GIT_DIR"
  git merge --no-ff "fix/bug" -m "merge fix/bug"

  bats_run_zsh "git-worktree-start ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$baseCommit" ]]
}

@test "fails when worktree has no commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-start"
  [[ "$status" -ne 0 ]]
}
