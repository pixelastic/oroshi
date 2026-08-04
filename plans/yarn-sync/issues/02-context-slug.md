## TLDR

New `context-slug` function returning a filesystem-safe identifier for the current context.

## What to build

Create `context-slug` in the `context/` domain. Accepts an optional path as first positional argument (defaults to `$PWD`). Returns:
- Repo Name when in Git Repo Main (e.g. `oroshi`)
- `<repoName>--<branchSlug>` when in a Worktree (e.g. `oroshi--yarn-sync`)

Repo Name is derived from `git-github-project-name`, falling back to the main directory basename with leading dots stripped. Uses `git-directory-is-worktree` to detect worktree context, `git-branch-current` and `git-branch-slug` for the branch part.

## Behavioral Tests

**From Git Repo Main:**
- returns the repo name without leading dots

**From a Worktree:**
- returns `repoName--branchSlug`

**With explicit path argument:**
- returns the correct slug for the given path, not `$PWD`

## Acceptance criteria

- [ ] `context-slug` exists in `context/` domain
- [ ] Returns repo name from main
- [ ] Returns `repoName--branchSlug` from worktree
- [ ] Accepts path as first positional argument
- [ ] Tests pass in `context/__tests__/context-slug.bats`
