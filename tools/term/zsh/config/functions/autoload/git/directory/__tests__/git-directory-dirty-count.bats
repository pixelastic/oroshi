bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  echo "world" > "$BATS_GIT_DIR/tracked2.txt"
  bats_git add tracked.txt tracked2.txt
  bats_git commit --quiet -m "init"
}

teardown() {
  bats_cleanup
}

@test "returns 0 for a clean worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-dirty-count"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "returns correct count for modified files" {
  echo "change" >> "$BATS_GIT_DIR/tracked.txt"
  echo "change" >> "$BATS_GIT_DIR/tracked2.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-dirty-count"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "counts staged files" {
  echo "staged" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-dirty-count"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "counts untracked files" {
  echo "untracked" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-dirty-count"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "accepts a path argument and counts from that path" {
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  echo "change" >> "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug/tracked.txt"
  bats_run_zsh "git-directory-dirty-count '$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug'"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
