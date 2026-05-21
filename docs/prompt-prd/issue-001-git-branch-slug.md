## PRD

[PRD.md](./PRD.md)

## What to build

A new autoload function `git-branch-slug` in the `git/branch/` namespace. It takes a branch name as its sole argument and returns the filesystem-safe slug: every `/` replaced with `_`. No other transformation.

This becomes the single source of truth for branch-name-to-slug conversion. `git-worktree-create` is updated to call it instead of its current inline substitution.

Bats tests cover: plain branch names, single slash, multiple slashes, names with hyphens and underscores.

## Acceptance criteria

- [ ] `git-branch-slug feat/my-feature` outputs `feat_my-feature`
- [ ] `git-branch-slug feat/scope/deep` outputs `feat_scope_deep`
- [ ] `git-branch-slug main` outputs `main` (no change)
- [ ] `git-worktree-create` uses `git-branch-slug` instead of inline substitution
- [ ] All bats tests pass

## Blocked by

None - can start immediately
