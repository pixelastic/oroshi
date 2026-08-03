bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

@test "skips files that are only staged (work-tree clean)" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-stageable-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "includes untracked files as A" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-stageable-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "untracked.txt▮A" ]]
}

@test "includes unstaged modified files as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-stageable-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮M" ]]
}

@test "file with spaces outputs without quotes" {
  echo "content" > "$BATS_GIT_DIR/my file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-dirty-stageable-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my file.txt▮A" ]]
}
