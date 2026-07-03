bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "content" > "$BATS_GIT_DIR/committed.txt"
  bats_git add committed.txt
  bats_git commit --quiet -m "initial commit"
}

@test "exits 0 when file exists in HEAD" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-in-head committed.txt"
  [ "$status" -eq 0 ]
}

@test "exits non-0 for untracked file" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-in-head untracked.txt"
  [ "$status" -ne 0 ]
}

@test "exits non-0 for staged-new file not yet committed" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-in-head staged.txt"
  [ "$status" -ne 0 ]
}
