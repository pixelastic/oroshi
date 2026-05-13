# issue-0008 — complete-git-worktrees + _git-worktrees

Completion function listing Worktrees of the current repo + the special `main` entry.

## Failing test

```bats
# scripts/bin/__tests__/complete-git-worktrees.bats

setup() {
  export TEST_TMP="$(mktemp -d)"
  export OROSHI_WORKTREES_DIR="$TEST_TMP/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"

  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug

  git init "$TEST_TMP/other-repo"
  cd "$TEST_TMP/other-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/other-repo--feat_x" -b feat/x
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "includes worktrees of the current repo" {
  cd "$TEST_TMP/my-repo"
  run complete-git-worktrees
  [[ "$output" == *"fix/bug"* ]]
}

@test "always includes 'main'" {
  cd "$TEST_TMP/my-repo"
  run complete-git-worktrees
  [[ "$output" == *"main"* ]]
}

@test "does not include worktrees from other repos" {
  cd "$TEST_TMP/my-repo"
  run complete-git-worktrees
  [[ "$output" != *"feat/x"* ]]
}
```

## What to implement

- `complete-git-worktrees` in `functions/autoload/completion/` — wraps `git-worktree-list-raw`, outputs lines in `branch:description` format; always prepends a `main` entry pointing to the Git Repo Main.
- `_git-worktrees` in `completion/compdef/` — standard `_describe` wrapper calling `complete-git-worktrees`.
- Wiring in `completion/compdef.zsh`: bind `_git-worktrees` to `git-worktree-switch` and `git-worktree-delete`.
