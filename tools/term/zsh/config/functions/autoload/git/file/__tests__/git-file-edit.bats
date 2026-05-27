bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "initial"
  cd "$BATS_GIT_DIR"
}

teardown() {
  bats_cleanup
}

@test "does nothing when working tree is clean" {
  bats_run_function git-file-edit
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "opens modified file in nvim" {
  echo "modified" > file.txt
  nvim() { echo "$*" > "$BATS_TMP_DIR/nvim.log"; }
  bats_mock nvim

  bats_run_function git-file-edit
  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/nvim.log")" == *"file.txt"* ]]
}

@test "does not open deleted files" {
  rm file.txt
  nvim() { echo "$*" > "$BATS_TMP_DIR/nvim.log"; }
  bats_mock nvim

  bats_run_function git-file-edit
  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/nvim.log" ]
}

@test "does not open renamed source file (old path no longer exists)" {
  git mv file.txt renamed.txt
  nvim() { echo "$*" > "$BATS_TMP_DIR/nvim.log"; }
  bats_mock nvim

  bats_run_function git-file-edit
  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/nvim.log")" == *"renamed.txt"* ]]
  [[ "$(cat "$BATS_TMP_DIR/nvim.log")" != *"file.txt"* ]]
}
