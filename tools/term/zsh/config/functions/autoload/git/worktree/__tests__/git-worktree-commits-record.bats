bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'
  bats_plans_dir
  bats_disable_worktree_aware

  # The plan directory of the worktree
  export PLAN_DIR="$MOCK_OROSHI_PLANS_DIR/my-repo--feature"
  plan-directory() { echo "$PLAN_DIR"; }
  bats_mock plan-directory
}

@test "records the commits ahead of main, oldest first" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "first"
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "second"
  local first="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD~1)"
  local second="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD)"

  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$PLAN_DIR/commits.json")" = "[\"$first\",\"$second\"]" ]]
}

@test "adds the new commits after a second record, without duplicates" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "first"
  local first="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD)"
  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"

  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "second"
  local second="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD)"
  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"

  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$PLAN_DIR/commits.json")" = "[\"$first\",\"$second\"]" ]]
}

@test "keeps the commits that are already in main after a push" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "first"
  local first="$(git -C "${BATS_GIT_WORKTREES}my-repo--feature" rev-parse HEAD)"
  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"

  # Push: main now holds the commit, so nothing is ahead anymore
  git -C "$BATS_GIT_DIR" merge --ff-only --quiet feature
  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"

  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$PLAN_DIR/commits.json")" = "[\"$first\"]" ]]
}

@test "writes nothing when no commit is ahead of main" {
  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$PLAN_DIR/commits.json" ]]
}

@test "writes nothing when there is no plan directory" {
  git -C "${BATS_GIT_WORKTREES}my-repo--feature" commit --allow-empty -m "first"
  plan-directory() { return 1; }
  bats_mock plan-directory

  bats_run_zsh "git-worktree-commits-record ${BATS_GIT_WORKTREES}my-repo--feature"
  [[ "$status" -eq 0 ]]
  [[ -z "$(find "$MOCK_OROSHI_PLANS_DIR" -type f)" ]]
}
