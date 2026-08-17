## TLDR

Update `git-worktree-rename` to rename the external plan directory.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-rename`:

1. Replace the local plans rename (`$oldDir/plans/$oldSlug` → `$newDir/plans/$newSlug`) with external rename.
2. Build old and new plan dirs via `plan-directory --project "$repoName" --branch "$oldBranch"` and `plan-directory --project "$repoName" --branch "$newBranch"`.
3. If old plan dir exists, `mv` it to the new path.

## Behavioral Tests

**git-worktree-rename.bats** (extend existing):
- Renaming worktree with plan → plan dir renamed in `$OROSHI_PLANS_DIR`
- Renaming worktree without plan → no error
- Plan dir content preserved after rename

## Scaffolding Tests

- No reference to local `plans/` directory in `git-worktree-rename`

## Acceptance criteria

- [ ] External plan dir renamed when worktree is renamed
- [ ] Plan content preserved
- [ ] No error when worktree has no plan
