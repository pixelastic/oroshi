load 'test_helper/zsh'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  git -C "$TMP_DIRECTORY/my-repo" commit --allow-empty -m "init"
  git -C "$TMP_DIRECTORY/my-repo" worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git -C "$TMP_DIRECTORY/my-repo" worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "output contains branch names" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/dark-mode"* ]]
}

@test "output does not contain file paths" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list
  [[ "$output" != *"$OROSHI_WORKTREES_DIR"* ]]
}

@test "returns empty output when no worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  git -C "$TMP_DIRECTORY/clean-repo" commit --allow-empty -m "init"
  cd "$TMP_DIRECTORY/clean-repo"
  run_zsh_fn git-worktree-list
  [ "$output" = "" ]
}
