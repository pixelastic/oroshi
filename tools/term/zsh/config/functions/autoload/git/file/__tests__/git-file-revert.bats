bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "original content" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "initial commit"
}

@test "restores modified tracked file to HEAD content" {
  echo "modified content" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert tracked.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_GIT_DIR/tracked.txt")" = "original content" ]
}

@test "restores deleted tracked file to disk" {
  rm "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert tracked.txt"
  [ "$status" -eq 0 ]
  [ -f "$BATS_GIT_DIR/tracked.txt" ]
}

@test "removes staged-new file from disk" {
  echo "new content" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert staged.txt"
  [ "$status" -eq 0 ]
  [ ! -f "$BATS_GIT_DIR/staged.txt" ]
}

@test "removes staged-new file from index" {
  echo "new content" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert staged.txt"
  [ "$status" -eq 0 ]
  local statusOutput="$(git -C "$BATS_GIT_DIR" status --porcelain)"
  [[ "$statusOutput" != *"staged.txt"* ]]
}

@test "removes untracked file from disk" {
  echo "untracked content" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert untracked.txt"
  [ "$status" -eq 0 ]
  [ ! -f "$BATS_GIT_DIR/untracked.txt" ]
}

@test "handles multiple files of mixed states in one call" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  echo "new staged" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  echo "untracked" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-revert tracked.txt staged.txt untracked.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_GIT_DIR/tracked.txt")" = "original content" ]
  [ ! -f "$BATS_GIT_DIR/staged.txt" ]
  [ ! -f "$BATS_GIT_DIR/untracked.txt" ]
}
