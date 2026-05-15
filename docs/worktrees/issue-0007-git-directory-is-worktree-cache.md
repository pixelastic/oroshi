# 0007 — `GIT_DIRECTORY_IS_WORKTREE` env cache

## What to build

Cache the result of `git-directory-is-worktree` in an environment variable
`GIT_DIRECTORY_IS_WORKTREE`, evaluated once per prompt cycle in
`oroshi-git-env-store` (the existing precmd hook that already caches
`GIT_DIRECTORY_IS_REPOSITORY`).

The variable follows the same convention: `1` inside a linked Worktree, `0`
otherwise.

Update `oroshi-prompt-populate:git_is_worktree` to read
`$GIT_DIRECTORY_IS_WORKTREE` instead of calling `git-directory-is-worktree`
directly, eliminating the redundant git call on every synchronous prompt render.

## Acceptance criteria

- [ ] `GIT_DIRECTORY_IS_WORKTREE` equals `1` inside a linked Worktree after `oroshi-git-env-store` runs
- [ ] `GIT_DIRECTORY_IS_WORKTREE` equals `0` in the Git Repo Main after `oroshi-git-env-store` runs
- [ ] `oroshi-prompt-populate:git_is_worktree` reads the cached variable (no direct `git-directory-is-worktree` call)

## Blocked by

None — can start immediately.
