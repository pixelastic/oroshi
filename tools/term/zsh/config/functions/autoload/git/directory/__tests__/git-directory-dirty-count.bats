bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-directory-dirty-count"
  cd "$BATS_GIT_DIR" || return
  echo "hello" > tracked.txt
  echo "world" > tracked2.txt
  git add tracked.txt tracked2.txt
  git commit -m "init"
}

teardown() {
  bats_cleanup
}

@test "returns 0 for a clean worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "returns correct count for modified files" {
  cd "$BATS_GIT_DIR"
  echo "change" >> tracked.txt
  echo "change" >> tracked2.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "counts staged files" {
  cd "$BATS_GIT_DIR"
  echo "staged" > staged.txt
  git add staged.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "counts untracked files" {
  cd "$BATS_GIT_DIR"
  echo "untracked" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "accepts a path argument and counts from that path" {
  export OROSHI_WORKTREES_DIR_MOCK="$BATS_TMP_DIR/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR_MOCK"
  cd "$BATS_GIT_DIR"
  git worktree add "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
