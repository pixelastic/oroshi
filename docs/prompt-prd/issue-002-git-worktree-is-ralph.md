## PRD

[PRD.md](./PRD.md)

## What to build

A new autoload function `git-worktree-is-ralph` in the `git/worktree/` namespace. Takes an optional path argument (any subpath inside a potential worktree); defaults to `$PWD` if omitted.

Exits 0 if — and only if — the path is inside a linked git worktree AND the file `docs/<branch-slug>/prd.json` exists at the worktree root. Exits 1 otherwise.

Uses `git-directory-is-worktree` directly (not the `GIT_DIRECTORY_IS_WORKTREE` env var) so it is callable outside the prompt context. Uses `git-branch-slug` (issue-001) to compute the slug.

Bats tests use temporary git worktrees. Covers: inside a ralph worktree (exit 0), inside a worktree without `prd.json` (exit 1), outside any worktree (exit 1), with an explicit path argument.

## Acceptance criteria

- [ ] Returns exit 0 when `$PWD` is inside a worktree with `docs/<slug>/prd.json`
- [ ] Returns exit 1 when `$PWD` is inside a worktree without `docs/<slug>/prd.json`
- [ ] Returns exit 1 when `$PWD` is not inside any worktree
- [ ] Accepts an explicit path argument and evaluates that path instead of `$PWD`
- [ ] Does not read `GIT_DIRECTORY_IS_WORKTREE` env var
- [ ] All bats tests pass

## Blocked by

- issue-001-git-branch-slug.md
