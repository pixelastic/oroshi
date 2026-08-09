bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'

  # Create and commit a file, then delete and commit the deletion
  echo "content" > "$BATS_GIT_DIR/deleted.txt"
  bats_git add deleted.txt
  bats_git commit --quiet -m "add deleted.txt"
  bats_git rm --quiet deleted.txt
  bats_git commit --quiet -m "remove deleted.txt"
}

@test "errors when no argument provided" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-resurrect"
  [[ "$status" -ne 0 ]]
}

@test "errors when file was never deleted in history" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-resurrect nonexistent.txt"
  [[ "$status" -ne 0 ]]
}

@test "restores a committed deletion" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-resurrect deleted.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_GIT_DIR/deleted.txt" ]]
  [[ "$(cat "$BATS_GIT_DIR/deleted.txt")" == "content" ]]
}

@test "works with absolute paths" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-resurrect $BATS_GIT_DIR/deleted.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_GIT_DIR/deleted.txt" ]]
}

@test "restores uncommitted deletion via checkout" {
  # Create a new file and commit it (not deleted in history)
  echo "alive" > "$BATS_GIT_DIR/alive.txt"
  bats_git -C "$BATS_GIT_DIR" add alive.txt
  bats_git -C "$BATS_GIT_DIR" commit --quiet -m "add alive.txt"

  # Delete it without committing
  rm "$BATS_GIT_DIR/alive.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-resurrect alive.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_GIT_DIR/alive.txt" ]]
  [[ "$(cat "$BATS_GIT_DIR/alive.txt")" == "alive" ]]
}
