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

@test "cds into the worktree directory" {
  cd "$TMP_DIRECTORY/my-repo"
  run zsh -c 'git-worktree-switch fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "cds to Git Repo Main when argument is 'main'" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run zsh -c 'git-worktree-switch main && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$TMP_DIRECTORY/my-repo" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-switch nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "returns 1 if called with no arguments" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-switch
  [ "$status" -eq 1 ]
}
