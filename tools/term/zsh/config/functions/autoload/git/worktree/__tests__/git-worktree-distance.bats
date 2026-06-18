bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

@test "returns ahead count when worktree has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  bats_run_zsh "git-worktree-distance"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 2"* ]]
  [[ "$output" == *"behind 0"* ]]
}

@test "returns behind count when main has commits not in worktree" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-distance"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 0"* ]]
  [[ "$output" == *"behind 3"* ]]
}

@test "returns ahead 0 behind 0 for fresh worktree" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-distance"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 0"* ]]
  [[ "$output" == *"behind 0"* ]]
}

@test "accepts a path argument and returns distance for that worktree" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  git commit --allow-empty -m "commit in worktree"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-distance ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 1"* ]]
  [[ "$output" == *"behind 0"* ]]
}
