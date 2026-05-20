load '../../../../../../../../scripts/bin/__tests__/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"

  git init "$TMP_DIRECTORY/repo"
  mkdir -p "$TMP_DIRECTORY/worktree"

  cd "$TMP_DIRECTORY/repo"
  git commit --allow-empty -m "init"

  git worktree add "$TMP_DIRECTORY/worktree/repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns 0 inside a linked worktree" {
  cd "$TMP_DIRECTORY/worktree/repo--fix_bug"
  run_zsh_fn git-directory-is-worktree
  [ "$status" -eq 0 ]
}

@test "returns 1 in the Git Repo Main" {
  cd "$TMP_DIRECTORY/repo"
  run_zsh_fn git-directory-is-worktree
  [ "$status" -eq 1 ]
}

@test "returns 1 outside any git repo" {
  cd "$TMP_DIRECTORY"
  run_zsh_fn git-directory-is-worktree
  [ "$status" -eq 1 ]
}

@test "accepts an explicit path argument" {
  run_zsh_fn git-directory-is-worktree "$TMP_DIRECTORY/worktree/repo--fix_bug"
  [ "$status" -eq 0 ]
}
