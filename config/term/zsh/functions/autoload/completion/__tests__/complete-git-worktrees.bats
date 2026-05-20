bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug

  git init "$TMP_DIRECTORY/other-repo"
  cd "$TMP_DIRECTORY/other-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/other-repo--feat_x" -b feat/x
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "includes worktrees of the current repo" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}

@test "always includes 'main'" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]
}

@test "does not include worktrees from other repos" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn complete-git-worktrees
  [ "$status" -eq 0 ]
  [[ "$output" != *"feat/x"* ]]
}

@test "outputs only 'main' when no linked worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  run_zsh_fn complete-git-worktrees
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "returns 'main' and succeeds outside a git repo" {
  cd "$TMP_DIRECTORY"
  run_zsh_fn complete-git-worktrees
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}
