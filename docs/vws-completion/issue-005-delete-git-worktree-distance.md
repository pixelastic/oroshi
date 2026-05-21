## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Delete `git-worktree-distance` and its bats test file. By the time this issue is reached, all callers (`git-worktree-list-raw`, `git-worktree-is-ahead`, `git-worktree-is-behind`, `prompt/git.zsh`) will have been migrated to `git-worktree-distance-raw`. Verify no remaining callers exist before deleting.

## Acceptance criteria

- [ ] `git-worktree-distance` function file is deleted
- [ ] `git-worktree-distance.bats` test file is deleted
- [ ] A grep for `git-worktree-distance` in the codebase (excluding the `distance-raw` variant) returns no results outside of git history

## Blocked by

- [issue-002](./issue-002-refactor-git-worktree-list-raw.md)
- [issue-003](./issue-003-refactor-is-ahead-is-behind.md)
- [issue-004](./issue-004-refactor-prompt-git-zsh.md)
