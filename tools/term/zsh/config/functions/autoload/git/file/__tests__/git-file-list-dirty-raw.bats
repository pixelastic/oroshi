bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-file-list-dirty-raw"
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

teardown() {
  bats_cleanup
}

@test "returns empty output for a clean repo" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lists untracked files as A" {
  cd "$BATS_GIT_DIR"
  echo "new" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "A:untracked.txt" ]
}

@test "lists unstaged modified files as M" {
  cd "$BATS_GIT_DIR"
  echo "modified" > tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists unstaged deleted files as D" {
  cd "$BATS_GIT_DIR"
  rm tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists staged new files as A" {
  cd "$BATS_GIT_DIR"
  echo "new" > staged.txt
  git add staged.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "A:staged.txt" ]
}

@test "lists staged modifications as M" {
  cd "$BATS_GIT_DIR"
  echo "modified" > tracked.txt
  git add tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists staged deletions as D" {
  cd "$BATS_GIT_DIR"
  git rm tracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists multiple dirty files" {
  cd "$BATS_GIT_DIR"
  echo "modified" > tracked.txt
  echo "new" > untracked.txt
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
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

@test "returns empty output for a clean path argument" {
  export OROSHI_WORKTREES_DIR_MOCK="$BATS_TMP_DIR/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR_MOCK"
  cd "$BATS_GIT_DIR"
  git worktree add "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug" -b fix/bug
  bats_run_zsh "$CURRENT" "$OROSHI_WORKTREES_DIR_MOCK/my-repo--fix_bug"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
