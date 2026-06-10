bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/file/git-file-list-dirty-raw"
  cd "$BATS_GIT_DIR" || return
  echo "hello" > tracked.txt
  git add tracked.txt
  git commit -m "init"
}

teardown() {
  bats_cleanup
}

@test "returns M:filepath for a modified tracked file" {
  cd "$BATS_GIT_DIR"
  echo "change" >> tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns A:filepath for a new untracked file" {
  cd "$BATS_GIT_DIR"
  echo "new" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"A:untracked.txt"* ]]
}

@test "returns D:filepath for a deleted tracked file" {
  cd "$BATS_GIT_DIR"
  rm tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"D:tracked.txt"* ]]
}

@test "returns empty output for a clean directory" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "accepts a path argument and lists dirty files in that path" {
  export OROSHI_WORKTREES_DIR_MOCK="$BATS_TMP_DIR/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR_MOCK"
  cd "$BATS_GIT_DIR"
  git worktree add "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug" -b fix/bug
  cd "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  echo "change" >> tracked.txt
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns empty output for a clean directory with path arg" {
  export OROSHI_WORKTREES_DIR_MOCK="$BATS_TMP_DIR/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR_MOCK"
  cd "$BATS_GIT_DIR"
  git worktree add "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug" -b fix/bug
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
