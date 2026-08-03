bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked"
}

@test "skips untracked files" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-staged-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "skips unstaged-only files" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-staged-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "includes staged new files as A" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-staged-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "staged.txt▮A" ]]
}

@test "includes staged modifications as M" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-staged-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "tracked.txt▮M" ]]
}

@test "file with spaces outputs without quotes" {
  echo "content" > "$BATS_GIT_DIR/my file.txt"
  bats_git add "my file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-list-staged-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "my file.txt▮A" ]]
}
