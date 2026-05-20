bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$TMP_DIRECTORY/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns 0 when worktree has commits ahead of main" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  git commit --allow-empty -m "unmerged"
  run_zsh_fn git-worktree-is-ahead
  [ "$status" -eq 0 ]
}

@test "returns 1 when worktree has no commits ahead of main" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run_zsh_fn git-worktree-is-ahead
  [ "$status" -eq 1 ]
}

@test "accepts a path argument" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  git commit --allow-empty -m "unmerged"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-is-ahead "$TMP_DIRECTORY/my-repo--fix_bug"
  [ "$status" -eq 0 ]
}
