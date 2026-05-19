# 0003 — Alias rename: `vwc/vwl/vws/vwR` + `vwsm`

## What to build

Rename the four worktree aliases in `worktree.zsh` to drop the `t`:

| Before | After | Function |
|--------|-------|----------|
| `vwtc` | `vwc` | `git-worktree-create` |
| `vwtl` | `vwl` | `git-worktree-list` |
| `vwts` | `vws` | `git-worktree-switch` |
| `vwtR` | `vwR` | `git-worktree-delete` |

Add `vwsm` as a new alias for `vws main` (returns to the Git Repo Main).

`compdef.zsh` requires no changes — completions are bound to functions, not
aliases.

## Acceptance criteria

- [ ] `vwc` resolves to `git-worktree-create`
- [ ] `vwl` resolves to `git-worktree-list`
- [ ] `vws` resolves to `git-worktree-switch`
- [ ] `vwR` resolves to `git-worktree-delete`
- [ ] `vwsm` resolves to `vws main` (or directly to `git-worktree-switch main`)
- [ ] Old aliases `vwtc`, `vwtl`, `vwts`, `vwtR` no longer exist

## Blocked by

None — can start immediately.
