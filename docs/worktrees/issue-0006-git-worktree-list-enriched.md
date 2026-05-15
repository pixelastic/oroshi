# 0006 — `git-worktree-list` enriched

## What to build

Rewrite `git-worktree-list` to display a rich columnar view of all linked
Worktrees, following the same pattern as `git-branch-list` (columnar output via
`table`, `▮` separator, existing colorize helpers).

Columns per row:
1. Current Worktree marker (▶ or blank) — detected by comparing `$PWD` to each worktree path
2. Branch name — `git-branch-colorize --with-icon`
3. Ahead/behind vs `main` — `git-distance-colorize --with-icon` via `git-worktree-distance`
4. Relative date of last commit — `git-date-colorize --with-icon`
5. Last commit message — `git-message-colorize`

## Acceptance criteria

- [ ] The Worktree currently active (matching `$PWD`) shows a pointer marker
- [ ] Each row shows the ahead count vs `main`
- [ ] Each row shows the behind count vs `main`
- [ ] Each row shows the relative date of the last commit
- [ ] Each row shows the last commit message

## Blocked by

- issue-0005 (`git-worktree-distance` must exist first)
