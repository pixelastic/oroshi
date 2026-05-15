# 0004 — `complete-git-worktrees-linked`

## What to build

A new completion function `complete-git-worktrees-linked` that lists only linked
Worktrees — no `main`. This is the completion set for destructive operations
where deleting the Git Repo Main is not a valid option.

Wire it via a new `_git-worktrees-linked` compdef wrapper. In `compdef.zsh`,
split the current `_git-worktrees` assignment:

- `git-worktree-switch` keeps `_git-worktrees` (includes `main`)
- `git-worktree-delete` switches to `_git-worktrees-linked` (excludes `main`)

The existing `complete-git-worktrees` (with `main`) is unchanged.

## Acceptance criteria

- [ ] `complete-git-worktrees-linked` output does not include `main`
- [ ] `complete-git-worktrees-linked` includes all linked worktree branch names
- [ ] `complete-git-worktrees-linked` returns empty output when no worktrees exist
- [ ] Autocomplete for `git-worktree-delete` uses the linked-only set
- [ ] Autocomplete for `git-worktree-switch` still includes `main`

## Blocked by

None — can start immediately.
