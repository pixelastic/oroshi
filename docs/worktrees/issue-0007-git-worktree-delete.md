# issue-0007 — git-worktree-delete

Removes a Worktree directory. Does NOT delete the branch. If called from inside the Worktree being deleted, first cds to the Git Repo Main.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-delete.bats

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

@test "removes the worktree directory" {
  cd "$TEST_TMP/my-repo"
  git-worktree-delete fix/bug
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "does not delete the branch" {
  cd "$TEST_TMP/my-repo"
  git-worktree-delete fix/bug
  run git branch --list fix/bug
  [ "$output" != "" ]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git-worktree-delete fix/bug
  [ "$PWD" = "$TEST_TMP/my-repo" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-delete nonexistent/branch
  [ "$status" -eq 1 ]
}
```

## What to implement

Function `git-worktree-delete` in `functions/autoload/git/worktree/`.

- Argument: branch name
- Looks up path from `git-worktree-list-raw`
- If currently inside the Worktree being deleted: cds to `git-worktree-main` first
- Calls `git worktree remove <path>`
- Does NOT delete the branch (see ADR 0002)
- Returns 1 with an error message if no matching Worktree found
