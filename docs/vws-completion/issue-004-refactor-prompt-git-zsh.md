## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Refactor `prompt/git.zsh` to replace its call to `git-worktree-distance` and the subsequent `"ahead N, behind M"` string parsing with a call to `git-worktree-distance-raw "$branch"` and `▮`-split parsing. The branch is already resolved in the prompt context; no path lookup is needed.

Prompt output behavior is unchanged.

## Acceptance criteria

- [ ] `prompt/git.zsh` no longer calls `git-worktree-distance`
- [ ] `prompt/git.zsh` parses `▮`-separated output from `git-worktree-distance-raw`
- [ ] Prompt displays ahead/behind counts correctly when the worktree diverges from main
- [ ] All existing `prompt/git.zsh.bats` tests pass without modification

## Blocked by

- [issue-001](./issue-001-create-git-worktree-distance-raw.md)
