## TLDR

Extend `context-slug` to accept `--project` and `--branch` overrides, each independent.

## What to build

Modify `tools/term/zsh/config/functions/autoload/context/context-slug` to:

1. Parse optional `--project <name>` and `--branch <name>` flags via `zparseopts`.
2. Resolution logic:
   - `path` = positional arg $1, default to `$PWD`
   - `project` = `--project` flag, or derived from `path` (existing logic)
   - `branch` = `--branch` flag, or derived from `path` (existing logic)
3. If not in a worktree and no `--branch` provided, return just `project` (existing behavior).
4. If `--branch` is provided, always return `project--branchSlug` even if not in a worktree.

Each flag is independent: `--project` alone derives branch from path; `--branch` alone derives project from path; both together ignore path entirely.

## Behavioral Tests

Existing `context-slug.bats` extended with:

- **no flags in worktree**: returns `repoName--branchSlug` (existing)
- **no flags on main**: returns `repoName` (existing)
- **--project only in worktree**: overrides project, branch from worktree context
- **--branch only on main**: project from repo, branch slug from flag
- **--project + --branch**: returns `project--branchSlug`, ignores path
- **--project + --branch + path**: same as above, path ignored
- **--branch with slashes**: branch is slugified (`feat/x` → `feat_x`)

## Acceptance criteria

- [ ] `--project` overrides project detection
- [ ] `--branch` overrides branch detection
- [ ] Flags are independent (mix and match)
- [ ] Path is ignored when both flags are provided
- [ ] Branch slug is applied to `--branch` values (slashes → underscores)
- [ ] All existing tests still pass
