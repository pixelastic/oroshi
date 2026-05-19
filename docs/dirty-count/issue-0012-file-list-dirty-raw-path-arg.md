## PRD

[prd-dirty-count.md](./prd-dirty-count.md)

## What to build

Add an optional path argument to `git-file-list-dirty-raw`. When a path is provided, git operations run against that path instead of the current directory. When omitted, fall back to `git-directory-root` (current behaviour, unchanged).

Output format is unchanged: one `STATUS:FILEPATH` line per dirty file, where STATUS is M, A, or D.

## Acceptance criteria

- [ ] `git-file-list-dirty-raw` returns dirty files when called from the current directory (existing behaviour preserved)
- [ ] `git-file-list-dirty-raw /path/to/worktree` returns dirty files in that path when called from a different directory
- [ ] Returns empty output for a clean directory (with or without path arg)
- [ ] Returns `M:filepath` for a modified tracked file
- [ ] Returns `A:filepath` for a new untracked file
- [ ] Returns `D:filepath` for a deleted tracked file

## Blocked by

None — can start immediately.
