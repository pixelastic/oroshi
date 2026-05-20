bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git branch -M main
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "fix work"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "fast-forwards main to current HEAD" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  local fixHead="$(git rev-parse HEAD)"
  run_zsh_fn git-worktree-push
  [ "$status" -eq 0 ]
  run git -C "$TMP_DIRECTORY/my-repo" rev-parse main
  [ "$output" = "$fixHead" ]
}

@test "returns 1 if history has diverged" {
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "main work"
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-push
  [ "$status" -ne 0 ]
}
