bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

teardown() {
  bats_cleanup
}

@test "returns empty output for a clean repo" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lists untracked files as A" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "A:untracked.txt" ]
}

@test "lists unstaged modified files as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists unstaged deleted files as D" {
  rm "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists staged new files as A" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "A:staged.txt" ]
}

@test "lists staged modifications as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists staged deletions as D" {
  bats_git rm tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists multiple dirty files" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "accepts a path argument and lists dirty files in that path" {
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  echo "change" >> "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug/tracked.txt"
  bats_run_zsh "git-file-list-dirty-raw '$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"M:tracked.txt"* ]]
}

@test "returns empty output for a clean path argument" {
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  bats_run_zsh "git-file-list-dirty-raw '$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug'"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
