# issue-0006 — git-worktree-switch

cds into a Worktree by branch name, or into the Git Repo Main when given `main`.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-switch.bats

setup() {
  export TEST_TMP="$(mktemp -d)"
  export OROSHI_WORKTREES_DIR="$TEST_TMP/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "cds into the worktree directory" {
  cd "$TEST_TMP/my-repo"
  git-worktree-switch fix/bug
  [ "$PWD" = "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "cds into the Git Repo Main when argument is 'main'" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git-worktree-switch main
  [ "$PWD" = "$TEST_TMP/my-repo" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-switch nonexistent/branch
  [ "$status" -eq 1 ]
}
```

## What to implement

Function `git-worktree-switch` in `functions/autoload/git/worktree/`.

- Argument: branch name or `main`
- If `main`: cds to `git-worktree-main`
- Otherwise: looks up path from `git-worktree-list-raw`, cds to it
- Returns 1 with an error message if no matching Worktree found
