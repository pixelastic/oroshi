# issue-0003 — git-worktree-list-raw

Parseable list of Worktrees for the current repo. Used by `git-worktree-list` and completion.

## Failing test

```bats
# scripts/bin/__tests__/git-worktree-list-raw.bats

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

@test "lists worktrees with branch and path on each line" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "fix/bug $OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
  [ "${lines[1]}" = "feat/dark-mode $OROSHI_WORKTREES_DIR/my-repo--feat_dark-mode" ]
}

@test "excludes the Git Repo Main from output" {
  cd "$TEST_TMP/my-repo"
  run git-worktree-list-raw
  for line in "${lines[@]}"; do
    [[ "$line" != *"$TEST_TMP/my-repo "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  git init "$TEST_TMP/clean-repo"
  cd "$TEST_TMP/clean-repo"
  git commit --allow-empty -m "init"
  run git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run git-worktree-list-raw
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}
```

## What to implement

Function `git-worktree-list-raw` in `functions/autoload/git/worktree/`.

- No arguments
- Outputs one line per linked Worktree: `<branch> <absolute-path>`
- Excludes the Git Repo Main
- Works from inside any Worktree or from the Git Repo Main
- Uses `git worktree list --porcelain` and parses the output
