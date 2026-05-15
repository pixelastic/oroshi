# 0002 — `git-worktree-create` — fix Repo Name

## What to build

Replace the `${repoMain:t}` expression in `git-worktree-create` with a call to
`git-github-project-name`; if no remote, fall back inline to the Git Repo Main
folder name stripping all leading dots. This fixes Worktree Directory Names for
repos whose folder has a leading dot (e.g. `.oroshi` → `oroshi--fix_bug`).

No other logic in `git-worktree-create` changes.

## Acceptance criteria

- [ ] Creating a worktree from a dot-prefixed repo folder produces a directory name without the leading dot (e.g. `oroshi--fix_bug`, not `.oroshi--fix_bug`)
- [ ] Creating a worktree from a normal repo folder continues to work as before
- [ ] Existing tests for `git-worktree-create` still pass

## Blocked by

- issue-0001 (`git-github-project-name` must exist — already done)
