## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Refactor `git-worktree-list-raw` to replace its inline `git rev-list --left-right --count` block with a call to `git-worktree-distance-raw "$entryBranch"`. Split the `▮`-separated result into `ahead` and `behind`. Fall back to `0` for both on failure.

Output format is unchanged: `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message`. Existing bats tests must pass without modification.

## Acceptance criteria

- [ ] `git-worktree-list-raw` no longer contains an inline `rev-list` call
- [ ] Output format is unchanged: `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message`
- [ ] All existing `git-worktree-list-raw.bats` tests pass without modification
- [ ] A worktree with commits ahead/behind main shows correct counts in the output

## Blocked by

- [issue-001](./issue-001-create-git-worktree-distance-raw.md)
