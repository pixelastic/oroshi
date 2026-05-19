## PRD

[prd-dirty-count.md](./prd-dirty-count.md)

## What to build

Add the Dirty Count column to `vwl` (`git-worktree-list`) and introduce the `COLOR_ALIAS_GIT_WORKTREE_DIRTY` color token.

Two changes in one slice (the color token only exists to serve this column):
1. Add `COLOR_ALIAS_GIT_WORKTREE_DIRTY=21` (violet, `#a78bfa`) to the color theme.
2. Update `git-worktree-list` to parse the new 7-field raw format and display a `±` column in `COLOR_ALIAS_GIT_WORKTREE_DIRTY`, hidden when `dirtyCount` is `0`.

The ahead/behind parsing also simplifies: direct integer fields, no string parsing of "ahead X, behind Y".

Column order in display: marker | branch | dirty | ahead | behind | date | message

## Acceptance criteria

- [ ] `COLOR_ALIAS_GIT_WORKTREE_DIRTY` is defined with value `21`
- [ ] Dirty count column appears with `±` icon in violet when a Worktree has uncommitted files
- [ ] Dirty count column is absent when all Worktrees are clean
- [ ] Column position is before ahead/behind
- [ ] Ahead and behind columns still display correctly
- [ ] Existing tests updated and passing

## Blocked by

- issue-0014 (`git-worktree-list-raw` new format)
