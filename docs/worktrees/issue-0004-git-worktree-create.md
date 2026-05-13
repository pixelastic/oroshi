# issue-0004 — git-worktree-create

Creates a Worktree for a branch (new or existing) and cds into it.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-create.bats

setup() {
  export TEST_TMP="$(mktemp -d)"
  export OROSHI_WORKTREES_DIR="$TEST_TMP/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "creates worktree directory with correct name" {
  cd "$TEST_TMP/my-repo"
  git-worktree-create fix/bug
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "creates the branch if it does not exist" {
  cd "$TEST_TMP/my-repo"
  git-worktree-create fix/new-branch
  run git branch --list fix/new-branch
  [ "$output" != "" ]
}

@test "does not fail if branch already exists" {
  cd "$TEST_TMP/my-repo"
  git branch fix/existing
  run git-worktree-create fix/existing
  [ "$status" -eq 0 ]
}

@test "is idempotent — does not fail if worktree already exists" {
  cd "$TEST_TMP/my-repo"
  git-worktree-create fix/bug
  run git-worktree-create fix/bug
  [ "$status" -eq 0 ]
}

@test "converts slashes to underscores in directory name" {
  cd "$TEST_TMP/my-repo"
  git-worktree-create feat/some/deep-branch
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--feat_some_deep-branch" ]
}
```

## What to implement

Function `git-worktree-create` in `functions/autoload/git/worktree/`.

- Argument: branch name (new or existing)
- Derives Branch Slug: replaces `/` with `_`
- Derives directory name: `<repo-name>--<branch-slug>` in `$OROSHI_WORKTREES_DIR`
- Creates the branch if it doesn't exist
- Calls `git worktree add`; if the Worktree already exists, skips creation silently
- cds into the created (or existing) Worktree directory
