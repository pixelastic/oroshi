bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
}

@test "no arg: returns short hash of HEAD in the current directory" {
  cd "$BATS_GIT_DIR"
  local expected="$(bats_git log --format='%h' --max-count 1)"
  bats_run_zsh "git-commit-current"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$expected" ]]
}

@test "path arg: returns short hash of HEAD in that repo" {
  local expected="$(bats_git log --format='%h' --max-count 1)"
  bats_disable_worktree_aware
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-commit-current $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$expected" ]]
}

@test "path arg: follows the commits of that repo" {
  bats_git commit --quiet --allow-empty --message "second"
  local expected="$(bats_git log --format='%h' --max-count 1)"
  bats_disable_worktree_aware
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-commit-current $BATS_GIT_DIR"
  [[ "$output" = "$expected" ]]
}

@test "path arg: fails outside a git repo" {
  bats_disable_worktree_aware
  bats_run_zsh "git-commit-current $BATS_TMP_DIR"
  [[ "$status" -ne 0 ]]
}
