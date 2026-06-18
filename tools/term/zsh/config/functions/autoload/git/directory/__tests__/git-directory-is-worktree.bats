bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  bats_git_worktree 'fix/bug'
}

@test "returns 0 inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}repo--fix-bug"
  bats_run_zsh "git-directory-is-worktree"
  [ "$status" -eq 0 ]
}

@test "returns 1 in the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-directory-is-worktree"
  [ "$status" -eq 1 ]
}

@test "returns 1 outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-directory-is-worktree"
  [ "$status" -eq 1 ]
}

@test "accepts an explicit path argument" {
  bats_run_zsh "git-directory-is-worktree ${BATS_GIT_WORKTREES}repo--fix-bug"
  [ "$status" -eq 0 ]
}
