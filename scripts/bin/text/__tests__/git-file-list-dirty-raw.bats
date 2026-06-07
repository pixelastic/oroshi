bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/file/git-file-list-dirty-raw"
  export TMP_DIRECTORY="$BATS_TMP_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo" || return
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "hello" > tracked.txt
  git add tracked.txt
  git commit -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns M:filepath for a modified tracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "change" >> tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns A:filepath for a new untracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "new" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"A:untracked.txt"* ]]
}

@test "returns D:filepath for a deleted tracked file" {
  cd "$TMP_DIRECTORY/my-repo"
  rm tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"D:tracked.txt"* ]]
}

@test "returns empty output for a clean directory" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "accepts a path argument and lists dirty files in that path" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns empty output for a clean directory with path arg" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
