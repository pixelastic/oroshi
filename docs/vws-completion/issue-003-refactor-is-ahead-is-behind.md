## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Refactor `git-worktree-is-ahead` and `git-worktree-is-behind` to use `git-worktree-distance-raw` internally. Both functions accept an optional path argument (defaulting to `$PWD`). The refactored pattern: resolve the branch via `git -C "$worktreePath" symbolic-ref --short HEAD`, then call `git-worktree-distance-raw "$branch"` from within that path's context (subshell `cd`), and check the relevant field.

External behavior is unchanged. All existing bats tests for both functions must pass without modification.

## Acceptance criteria

- [ ] `git-worktree-is-ahead` no longer contains an inline `rev-list` call
- [ ] `git-worktree-is-behind` no longer contains an inline `rev-list` call
- [ ] Both functions still accept an optional path argument
- [ ] All existing `git-worktree-is-ahead.bats` tests pass without modification
- [ ] All existing `git-worktree-is-behind.bats` tests pass without modification

## Blocked by

- [issue-001](./issue-001-create-git-worktree-distance-raw.md)
