load '../../../../../../../../config/term/bats/helper'

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

@test "prints the worktree path for a given branch" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-path fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "returns 1 if branch has no worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-path nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "works from inside a linked worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-path fix/bug
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}
