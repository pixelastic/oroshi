bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns git-dir for a directory inside a worktree" {
  bats_run_zsh "git-directory-gitdir ${BATS_GIT_WORKTREES}repo--fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *".git/worktrees/"* ]]
}

@test "returns git-dir when given a file path inside a worktree" {
  local testFile="${BATS_GIT_WORKTREES}repo--fix-bug/somefile.txt"
  touch "$testFile"
  bats_run_zsh "git-directory-gitdir $testFile"
  [ "$status" -eq 0 ]
  [[ "$output" == *".git/worktrees/"* ]]
}

@test "returns empty string outside any git repo" {
  bats_run_zsh "git-directory-gitdir $BATS_TMP_DIR"
  [ "$output" = "" ]
}
