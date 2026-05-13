# issue-0005 — git-worktree-list

Human-readable list of Worktrees for the current repo. Displays branch names only, colored by branch convention.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-list.bats

setup() {
  export TEST_TMP="$(mktemp -d)"
  export OROSHI_WORKTREES_DIR="$TEST_TMP/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" -b feat/dark-mode
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "output contains branch names" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
  [[ "$output" == *"feat/dark-mode"* ]]
}

@test "output does not contain file paths" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-list
  [[ "$output" != *"$OROSHI_WORKTREES_DIR"* ]]
}

@test "returns empty output when no worktrees exist" {
  git init "$TEST_TMP/clean-repo"
  cd "$TEST_TMP/clean-repo"
  git commit --allow-empty -m "init"
  run git-worktree-list
  [ "$output" = "" ]
}
```

## What to implement

Function `git-worktree-list` in `functions/autoload/git/worktree/`.

- No arguments
- Wraps `git-worktree-list-raw`, extracts branch names, colorizes via `git-branch-colorize`
- Does not display file paths
