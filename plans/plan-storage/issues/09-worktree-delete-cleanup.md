## TLDR

Update `git-worktree-delete` to clean up the external plan directory.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-delete`:

1. Replace the local plans cleanup (`$mainPath/plans/$branchSlug`) with external cleanup.
2. Resolve the plan dir for the worktree being deleted. Use `plan-directory "$worktreePath"` or build via `plan-directory --project "$repoName" --branch "$branch"`.
3. If the plan dir exists, `rm -rf` it (removes the plan git repo entirely).
4. Update the `ralph-is-running` check to use the external plan dir (already handled by issue 04's `ralph-is-running` rewrite — just verify it works here).

## Behavioral Tests

**git-worktree-delete.bats** (extend existing):
- Deleting worktree with associated external plan → plan dir removed from `$OROSHI_PLANS_DIR`
- Deleting worktree without plan → no error
- Ralph guard still works with external plan dir

## Scaffolding Tests

- No reference to `$mainPath/plans/` in `git-worktree-delete`

## Acceptance criteria

- [ ] External plan dir deleted when worktree is deleted
- [ ] No error when worktree has no plan
- [ ] Ralph-is-running guard still blocks deletion when ralph.json exists
