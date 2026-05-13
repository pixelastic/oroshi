# issue-0002 — git-worktree-main

Returns the absolute path of the Git Repo Main from anywhere.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-main.bats

setup() {
  export TEST_TMP="$(mktemp -d)"
  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
  mkdir -p "$TEST_TMP/worktrees"
  git worktree add "$TEST_TMP/worktrees/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "returns Git Repo Main path from inside a linked worktree" {
  cd "$TEST_TMP/worktrees/my-repo--fix_bug"
  run git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_TMP/my-repo" ]
}

@test "returns own path when called from the Git Repo Main" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-main
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_TMP/my-repo" ]
}

@test "returns 1 outside any git repo" {
  cd "$TEST_TMP"
  run git-worktree-main
  [ "$status" -eq 1 ]
}
```

## What to implement

Function `git-worktree-main` in `functions/autoload/git/worktree/`.

- No arguments
- Returns the absolute path of the Git Repo Main
- Works from inside a linked Worktree or from the Git Repo Main itself
- Detection: `git rev-parse --git-common-dir` returns the shared `.git` directory; its parent is the Git Repo Main
