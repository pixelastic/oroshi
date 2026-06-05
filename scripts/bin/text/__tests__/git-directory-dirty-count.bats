bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/directory/git-directory-dirty-count"
  export TMP_DIRECTORY="$BATS_TMP_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "hello" > tracked.txt
  echo "world" > tracked2.txt
  git add tracked.txt tracked2.txt
  git commit -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns 0 for a clean worktree" {
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "returns correct count for modified files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "change" >> tracked.txt
  echo "change" >> tracked2.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "counts staged files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "staged" > staged.txt
  git add staged.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "counts untracked files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "untracked" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "accepts a path argument and counts from that path" {
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  cd "$TMP_DIRECTORY/my-repo"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$TMP_DIRECTORY/my-repo"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
