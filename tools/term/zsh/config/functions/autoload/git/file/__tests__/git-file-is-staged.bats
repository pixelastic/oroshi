bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "content" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "initial commit"
}

@test "exits 0 for staged-new file" {
  echo "new" > "$BATS_GIT_DIR/staged.txt"
  bats_git add staged.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-is-staged staged.txt"
  [ "$status" -eq 0 ]
}

@test "exits 0 for staged modification of committed file" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-is-staged tracked.txt"
  [ "$status" -eq 0 ]
}

@test "exits non-0 for untracked file" {
  echo "new" > "$BATS_GIT_DIR/untracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-is-staged untracked.txt"
  [ "$status" -ne 0 ]
}

@test "exits non-0 for committed file with no staged changes" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-is-staged tracked.txt"
  [ "$status" -ne 0 ]
}
