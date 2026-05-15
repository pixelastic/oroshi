# 0005 — `git-worktree-distance`

## What to build

A new helper in the `git/worktree/` family that returns the ahead/behind commit
count between the current worktree branch and `main`.

Output format mirrors `git-branch-distance` (`"ahead X, behind Y"`) so that
`git-distance-colorize` can consume it without adaptation.

Extracting this as a standalone helper avoids duplicating the git call across
`git-worktree-list` and `git_worktree_branch`, and makes the distance
independently testable.

## Acceptance criteria

- [ ] Returns `ahead 2` (or similar) when the worktree has 2 commits not in `main`
- [ ] Returns `behind 3` (or similar) when `main` has 3 commits not in the worktree
- [ ] Returns `ahead 0, behind 0` for a fresh worktree with no divergence

## Blocked by

None — can start immediately.
