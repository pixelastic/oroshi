load '../../../../../../../../config/term/bats/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
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
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "marks current worktree with pointer" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *""* ]]
}

@test "shows ahead count vs main" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "commit one"
  git commit --allow-empty -m "commit two"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* ]]
}

@test "shows behind count vs main" {
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "main commit 1"
  git commit --allow-empty -m "main commit 2"
  git commit --allow-empty -m "main commit 3"
  run zsh -c 'git-worktree-list | sed "s/\x1b\[[0-9;]*m//g"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"3"* ]]
}

@test "shows relative date of last commit" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "dated commit"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"seconds"* ]]
}

@test "shows last commit message" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "my test commit"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"my test commit"* ]]
}
