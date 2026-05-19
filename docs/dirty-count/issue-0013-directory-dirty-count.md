## PRD

[prd-dirty-count.md](./prd-dirty-count.md)

## What to build

New deep module `git-directory-dirty-count` in the `git/directory/` domain. Accepts an optional path argument. Returns the number of dirty files (staged, unstaged, untracked) in that directory as an integer. Returns `0` for a clean directory. Always exits 0.

Implementation: calls `git-file-list-dirty-raw [path]` and counts output lines. No direct git calls — delegates to the raw helper so that a bug fixed in the raw propagates here automatically.

## Acceptance criteria

- [ ] Returns `0` for a clean Worktree
- [ ] Returns the correct count when files are modified (unstaged)
- [ ] Counts staged files
- [ ] Counts untracked files
- [ ] Accepts a path argument and counts dirty files in that path from a different directory
- [ ] Always exits 0

## Blocked by

- issue-0012 (`git-file-list-dirty-raw` path arg)
