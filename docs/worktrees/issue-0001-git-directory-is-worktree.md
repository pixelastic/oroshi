# issue-0001 — git-directory-is-worktree

Boolean: is the current (or given) path a linked Worktree?

## Failing test

```bats
# scripts/bin/__tests__/git-directory-is-worktree.bats

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

@test "returns 0 inside a linked worktree" {
  cd "$TEST_TMP/worktrees/my-repo--fix_bug"
  run git-directory-is-worktree
  [ "$status" -eq 0 ]
}

@test "returns 1 in the Git Repo Main" {
  cd "$TEST_TMP/my-repo"
  run git-directory-is-worktree
  [ "$status" -eq 1 ]
}

@test "returns 1 outside any git repo" {
  cd "$TEST_TMP"
  run git-directory-is-worktree
  [ "$status" -eq 1 ]
}

@test "accepts an explicit path argument" {
  run git-directory-is-worktree "$TEST_TMP/worktrees/my-repo--fix_bug"
  [ "$status" -eq 0 ]
}
```

## What to implement

Function `git-directory-is-worktree` in `functions/autoload/git/directory/`.

- Optional path argument, defaults to `$PWD`
- Returns 0 (true) if the path is a linked Worktree
- Returns 1 (false) if it is the Git Repo Main or not a git repo at all
- Detection: `git rev-parse --git-dir` returns an absolute path containing `.git/worktrees/` for linked worktrees; returns `.git` (relative) for the main worktree
