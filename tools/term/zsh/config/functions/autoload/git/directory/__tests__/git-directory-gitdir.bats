bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-directory-gitdir"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns git-dir for a directory inside a worktree" {
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *".git/worktrees/"* ]]
}

@test "returns git-dir when given a file path inside a worktree" {
  local testFile="${BATS_GIT_WORKTREES}fix-bug/somefile.txt"
  touch "$testFile"
  bats_run_zsh "$CURRENT" "$testFile"
  [ "$status" -eq 0 ]
  [[ "$output" == *".git/worktrees/"* ]]
}

@test "returns empty string outside any git repo" {
  bats_run_zsh "$CURRENT" "$BATS_TMP_DIR"
  [ "$output" = "" ]
}
