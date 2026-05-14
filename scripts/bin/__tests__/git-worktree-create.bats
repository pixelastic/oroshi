load 'test_helper/zsh'

setup() {
  git_env_clean
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git -C "$TMP_DIRECTORY/my-repo" commit --allow-empty -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "creates worktree directory with correct name" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 0 ]
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "creates the branch if it does not exist" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/new-branch
  run git -C "$TMP_DIRECTORY/my-repo" branch --list fix/new-branch
  [ "$output" != "" ]
}

@test "does not fail if branch already exists" {
  git -C "$TMP_DIRECTORY/my-repo" branch fix/existing
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/existing
  [ "$status" -eq 0 ]
}

@test "cds into the created worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  run zsh -c 'git-worktree-create fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "is idempotent — does not fail if worktree already exists" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create fix/bug
  run_zsh_fn git-worktree-create fix/bug
  [ "$status" -eq 0 ]
}

@test "converts slashes to underscores in directory name" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-create feat/some/deep-branch
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--feat_some_deep-branch" ]
}
