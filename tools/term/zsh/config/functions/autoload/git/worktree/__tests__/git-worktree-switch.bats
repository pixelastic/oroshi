bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

@test "cds into the worktree directory" {
  cd "$BATS_GIT_DIR"
  local script="$BATS_TMP_DIR/switch-test.zsh"
  printf 'git-worktree-switch fix/bug && echo "$PWD"\n' >"$script"
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}my-repo--fix-bug" ]
}

@test "cds to Git Repo Main when argument is 'main'" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local script="$BATS_TMP_DIR/switch-main.zsh"
  printf 'git-worktree-switch main && echo "$PWD"\n' >"$script"
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-switch nonexistent/branch"
  [ "$status" -eq 1 ]
}

@test "returns 1 if called with no arguments" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-switch"
  [ "$status" -eq 1 ]
}
