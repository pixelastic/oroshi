bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

@test "returns empty output for a clean repo" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "lists untracked files as A" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "untracked.txt▮A" ]]
}

@test "lists unstaged modified files as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮M" ]]
}

@test "lists unstaged deleted files as D" {
  rm "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮D" ]]
}

@test "lists staged new files as A" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "staged.txt▮A" ]]
}

@test "lists staged modifications as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮M" ]]
}

@test "lists staged deletions as D" {
  bats_git rm tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮D" ]]
}

@test "lists multiple dirty files" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "preserves rename three-column format from git-status-raw" {
  bats_git mv tracked.txt renamed.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"renamed.txt▮R▮tracked.txt"* ]]
}

@test "accepts a path argument and lists dirty files in that path" {
  bats_disable_worktree_aware
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  echo "change" >> "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug/tracked.txt"
  bats_run_zsh "git-file-list-dirty-raw '$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"tracked.txt▮M"* ]]
}

@test "file with spaces in path outputs without quotes" {
  echo "content" > "$BATS_GIT_DIR/my file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my file.txt▮A" ]]
}

# Submodule tests

@test "--include-submodules lists dirty submodule files prefixed with submodule path" {
  bats_git_submodule "$BATS_GIT_DIR" my-sub
  echo "content" > "$BATS_GIT_DIR/my-sub/sub-file.txt"
  git -C "$BATS_GIT_DIR/my-sub" add sub-file.txt
  git -C "$BATS_GIT_DIR/my-sub" commit --quiet -m "add sub-file"
  echo "modified" > "$BATS_GIT_DIR/my-sub/sub-file.txt"

  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw --include-submodules"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"my-sub/sub-file.txt▮M"* ]]
}

@test "--include-submodules lists both top-level and submodule dirty files" {
  bats_git_submodule "$BATS_GIT_DIR" my-sub
  echo "content" > "$BATS_GIT_DIR/my-sub/sub-file.txt"
  git -C "$BATS_GIT_DIR/my-sub" add sub-file.txt
  git -C "$BATS_GIT_DIR/my-sub" commit --quiet -m "add sub-file"
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  echo "modified" > "$BATS_GIT_DIR/my-sub/sub-file.txt"

  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw --include-submodules"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"tracked.txt▮M"* ]]
  [[ "$output" == *"my-sub/sub-file.txt▮M"* ]]
}

@test "--include-submodules returns empty when top-level and submodules are clean" {
  bats_git_submodule "$BATS_GIT_DIR" my-sub

  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw --include-submodules"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "without --include-submodules does not list submodule inner files" {
  bats_git_submodule "$BATS_GIT_DIR" my-sub
  echo "content" > "$BATS_GIT_DIR/my-sub/sub-file.txt"
  git -C "$BATS_GIT_DIR/my-sub" add sub-file.txt
  git -C "$BATS_GIT_DIR/my-sub" commit --quiet -m "add sub-file"
  echo "modified" > "$BATS_GIT_DIR/my-sub/sub-file.txt"

  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"sub-file.txt"* ]]
}

@test "returns empty output for a clean path argument" {
  bats_disable_worktree_aware
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  bats_run_zsh "git-file-list-dirty-raw '$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
