load '../../../../../../../../scripts/bin/__tests__/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "lists worktrees with branch and path on each line" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮$OROSHI_WORKTREES_DIR/my-repo--fix_bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-list-raw
  for line in "${lines[@]}"; do
    [[ "$line" != *"$TMP_DIRECTORY/my-repo "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run_zsh_fn git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}
