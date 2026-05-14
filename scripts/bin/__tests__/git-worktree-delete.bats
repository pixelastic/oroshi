load 'test_helper/zsh'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  git -C "$TMP_DIRECTORY/my-repo" commit --allow-empty -m "init"
  git -C "$TMP_DIRECTORY/my-repo" worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "removes the worktree directory" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "does not delete the branch" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug
  run git -C "$TMP_DIRECTORY/my-repo" branch --list fix/bug
  [ "$output" != "" ]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run zsh -c 'git-worktree-delete fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$TMP_DIRECTORY/my-repo" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete nonexistent/branch
  [ "$status" -eq 1 ]
}
