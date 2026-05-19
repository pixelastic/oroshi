## PRD

[prd-dirty-count.md](./prd-dirty-count.md)

## What to build

Update `git-worktree-list-raw` to output a new 7-field format that mirrors the display column order of `git-worktree-list`:

```
branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message
```

Two changes combined in a single slice (they break the same consumer at the same time):
1. Split the `distance` string ("ahead X, behind Y") into two separate integer fields `ahead` and `behind`.
2. Insert `dirtyCount` (from `git-directory-dirty-count`) as the third field.

Update the existing bats tests for `git-worktree-list-raw` to match the new format.

## Acceptance criteria

- [ ] Output contains 7 `▮`-separated fields per line
- [ ] Field order: `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message`
- [ ] `dirtyCount` is `0` for a fresh Worktree with no uncommitted files
- [ ] `dirtyCount` reflects actual dirty file count for a Worktree with uncommitted changes
- [ ] `ahead` is an integer (e.g. `2`, not `"ahead 2"`)
- [ ] `behind` is an integer (e.g. `3`, not `"behind 3"`)
- [ ] Existing tests updated and passing

## Blocked by

- issue-0013 (`git-directory-dirty-count`)
