bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  echo "hello" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "init"
}

@test "returns empty output when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "returns filepath with Modified label for modified file" {
  echo "changed" > "$BATS_GIT_DIR/file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "file.txt:~ Modified" ]
}

@test "returns filepath with Deleted label for deleted file" {
  rm "$BATS_GIT_DIR/file.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "file.txt:- Deleted" ]
}

@test "returns filepath with New file label for untracked file" {
  echo "new" > "$BATS_GIT_DIR/new.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "new.txt:+ New file" ]
}

@test "returns filepath with New file label for staged-new file" {
  echo "staged" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "staged.txt:+ New file" ]
}

@test "lists all dirty files across types" {
  echo "changed" > "$BATS_GIT_DIR/file.txt"
  rm "$BATS_GIT_DIR/file.txt"
  echo "new" > "$BATS_GIT_DIR/new.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && complete-git-files-dirty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"new.txt:+ New file"* ]]
  [[ "$output" == *"file.txt:- Deleted"* ]]
}
