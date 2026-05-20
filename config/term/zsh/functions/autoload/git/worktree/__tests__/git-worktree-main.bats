bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"

  mkdir -p "$TMP_DIRECTORY/worktrees"
  git worktree add "$TMP_DIRECTORY/worktrees/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns Git Repo Main path from inside a linked worktree" {
  cd "$TMP_DIRECTORY/worktrees/my-repo--fix_bug"
  run_zsh_fn git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$TMP_DIRECTORY/my-repo" ]
}

@test "returns own path when called from the Git Repo Main" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$TMP_DIRECTORY/my-repo" ]
}

@test "returns 1 outside any git repo" {
  cd "$TMP_DIRECTORY"
  run_zsh_fn git-worktree-main
  [ "$status" -eq 1 ]
}
