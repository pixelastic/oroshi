## TLDR

Add a hard-block ralph guard to `git-worktree-delete` and fix the plans path bug.

## What to build

Three changes to `git-worktree-delete`, applied together:

**1. Move `branchSlug` computation earlier** — `branchSlug` is currently computed after the destructive `git worktree remove` / `git-branch-remove` steps. Move it to before the destructive steps so it is available for the ralph guard.

**2. Add a hard-block ralph guard** — after the existing unmerged-commits check, add a check using `ralph-is-running "$worktreePath/plans/$branchSlug"`. If a session is active, print an error and return 1. This guard is NOT bypassed by `--force`.

**3. Fix plans path bug** — the existing plans directory cleanup uses the main worktree path as the base. It should use `$worktreePath` (the branch worktree being deleted), since plans live inside the branch worktree at `<worktreePath>/plans/<branchSlug>`.

Add tests to `git-worktree-delete.bats`:
- blocks deletion when a ralph session is active
- `--force` does NOT bypass the ralph guard
- plans directory is cleaned from the branch worktree path, not the main repo path

## Behavioral Tests

**Ralph guard:**
- blocks deletion when `ralph.json` exists in the plan dir of the worktree being deleted
- `--force` does not bypass the ralph guard (still blocks)
- allows deletion when no ralph session is active

**Plans path fix:**
- plans directory at `<worktreePath>/plans/<branchSlug>` is removed on successful deletion

## Acceptance criteria

- [ ] `branchSlug` computed before destructive steps
- [ ] Deletion blocked (exit 1) when ralph session is active in the target worktree's plan dir
- [ ] `--force` does not bypass the ralph guard
- [ ] Error message clearly indicates ralph is running
- [ ] Plans dir cleanup uses `$worktreePath` as base, not `$mainPath`
- [ ] `git-worktree-delete.bats` updated with new tests
- [ ] All existing tests still pass
- [ ] Linting passes
