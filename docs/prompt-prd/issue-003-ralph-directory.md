## PRD

[PRD.md](./PRD.md)

## What to build

A new script `ralph-directory` in the ralph domain (`scripts/bin/ai/ralph/`), sibling of `ralph-end`. Takes an optional path argument (any subpath inside a potential worktree); defaults to `$PWD` if omitted.

Calls `git-worktree-is-ralph` internally. If it exits 1 (not a ralph worktree), `ralph-directory` exits 1 and returns nothing. If it exits 0, returns the **absolute path** to the ralph prd directory: `<worktree-root>/docs/<branch-slug>/`.

Bats tests use temporary git worktrees. Covers: no argument (PWD is inside a ralph worktree), explicit path argument, path not in a worktree (exit 1), path in a worktree without prd.json (exit 1), verify the returned path is absolute.

## Acceptance criteria

- [ ] Returns the absolute path to `docs/<slug>/` when inside a ralph worktree
- [ ] Returns exit 1 when not inside a ralph worktree
- [ ] Returns exit 1 when inside a worktree without `prd.json`
- [ ] Returned path is absolute (starts with `/`)
- [ ] Accepts an optional path argument
- [ ] All bats tests pass

## Blocked by

- issue-001-git-branch-slug.md
- issue-002-git-worktree-is-ralph.md
