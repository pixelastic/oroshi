## PRD

[prd-dirty-count.md](./prd-dirty-count.md)

## What to build

Update `git-file-edit` to accept an optional path argument. When provided, it lists and opens dirty files from that path instead of the current directory. Full file paths are reconstructed relative to the provided path (not `git-directory-root`).

Lower priority — the core dirty count feature in `vwl` does not depend on this slice.

## Acceptance criteria

- [ ] `git-file-edit` with no argument opens dirty files in the current directory (existing behaviour preserved)
- [ ] `git-file-edit /path/to/worktree` opens dirty files from that Worktree
- [ ] Deleted files are still skipped (can't open them in nvim)
- [ ] ralph-managed files (`progress.md`, `prd.json`) are still skipped

## Blocked by

- issue-0012 (`git-file-list-dirty-raw` path arg)
