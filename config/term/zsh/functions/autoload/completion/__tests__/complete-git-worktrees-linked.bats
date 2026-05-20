load '../../../../../../../scripts/bin/__tests__/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_thing" -b feat/thing
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "does not include 'main'" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [[ "$output" != *"main"* ]]
}

@test "includes linked worktree branch names" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/thing"* ]]
}

@test "returns empty output when no worktrees exist" {
  git init "$TMP_DIRECTORY/clean-repo"
  cd "$TMP_DIRECTORY/clean-repo"
  git commit --allow-empty -m "init"
  run_zsh_fn complete-git-worktrees-linked
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
