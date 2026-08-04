bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  # Create a committed file
  echo "original" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet -m "add tracked file"
}

# --- Without --repo ---

@test "exits 0 when file has uncommitted changes" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file has no changes" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-has-changed tracked.txt"
  [[ "$status" -ne 0 ]]
}

# --- With --repo ---

@test "exits 0 when file has changes in --repo target" {
  echo "modified" > "$BATS_GIT_DIR/tracked.txt"
  bats_run_zsh "cd /tmp && git-file-has-changed tracked.txt --repo $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
}

@test "exits non-0 when file has no changes in --repo target" {
  bats_run_zsh "cd /tmp && git-file-has-changed tracked.txt --repo $BATS_GIT_DIR"
  [[ "$status" -ne 0 ]]
}
