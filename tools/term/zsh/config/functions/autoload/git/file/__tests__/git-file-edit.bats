bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "initial"
}

@test "does nothing when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "opens modified file in nvim" {
  echo "modified" > "$BATS_GIT_DIR/file.txt"
  nvim() { echo "$*"; }
  bats_mock nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"file.txt"* ]]
}

@test "does not open deleted files" {
  rm "$BATS_GIT_DIR/file.txt"
  nvim() { echo "$*"; }
  bats_mock nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "does not open useless files" {
  echo "x" > "$BATS_GIT_DIR/yarn.lock"
  echo "x" > "$BATS_GIT_DIR/font.woff2"
  mkdir -p "$BATS_GIT_DIR/plans/my-plan/scaffold"
  echo "x" > "$BATS_GIT_DIR/plans/my-plan/state.json"
  echo "x" > "$BATS_GIT_DIR/plans/my-plan/scaffold/template.lua"
  echo "x" > "$BATS_GIT_DIR/useful.txt"
  bats_git add .
  nvim() { echo "$*"; }
  bats_mock nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == "-p $BATS_GIT_DIR/useful.txt" ]]
}

@test "does not open renamed source file (old path no longer exists)" {
  git -C "$BATS_GIT_DIR" mv file.txt renamed.txt
  nvim() { echo "$*"; }
  bats_mock nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"renamed.txt"* ]]
  [[ "$output" != *"file.txt"* ]]
}
