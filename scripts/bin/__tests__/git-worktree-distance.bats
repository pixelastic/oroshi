load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns ahead count when worktree has commits ahead of main" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  run_zsh_fn git-worktree-distance
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 2"* ]]
}

@test "returns behind count when main has commits not in worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-distance
  [ "$status" -eq 0 ]
  [[ "$output" == *"behind 3"* ]]
}

@test "returns ahead 0 behind 0 for fresh worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-distance
  [ "$status" -eq 0 ]
  [[ "$output" == *"ahead 0"* ]]
  [[ "$output" == *"behind 0"* ]]
}
