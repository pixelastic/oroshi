bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
}

@test "lists files deleted in history" {
  echo "content" > "$BATS_GIT_DIR/removed.txt"
  bats_git add removed.txt
  bats_git commit --quiet -m "add removed.txt"
  bats_git rm --quiet removed.txt
  bats_git commit --quiet -m "delete removed.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-deleted"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"removed.txt"* ]]
}

@test "returns empty output when no files were deleted" {
  echo "content" > "$BATS_GIT_DIR/kept.txt"
  bats_git add kept.txt
  bats_git commit --quiet -m "add kept.txt"

  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-deleted"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "deduplicates files deleted multiple times" {
  echo "v1" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "add file"
  bats_git rm --quiet file.txt
  bats_git commit --quiet -m "delete file"

  echo "v2" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "re-add file"
  bats_git rm --quiet file.txt
  bats_git commit --quiet -m "delete file again"

  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-deleted"
  [[ "$status" -eq 0 ]]
  # Should appear exactly once
  local count
  count="$(echo "$output" | grep -c '^file.txt$')"
  [[ "$count" -eq 1 ]]
}
