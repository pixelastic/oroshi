## TLDR

Create `plan-start` script (from `prd-end`) with simplified JSON output, migrate existing tests.

## What to build

Create `scripts/bin/ai/plan/plan-start` by adapting `scripts/bin/ai/prd/prd-end`. Same core logic (worktree creation, branch detection), but simplified output: `{ worktreePath, branch, planDir }` instead of `{ worktreePath, branch, prdPath, commitHintPath }`.

`planDir` is `$root/plans/$slug/` — the skill derives all file paths from it.

## Behavioral Tests

Migrate from `scripts/bin/ai/prd/__tests__/prd-end.bats` — 80-90% identical, adapted for new output shape.

- planDir contains `plans/<slug>/`
- outputs worktreePath and branch fields
- exits 1 when not in worktree and no branch given
- output does not contain prdPath or commitHintPath (removed fields)

## Acceptance criteria

- [ ] `scripts/bin/ai/plan/plan-start` exists and is executable
- [ ] Output is `{ worktreePath, branch, planDir }` — no other fields
- [ ] `planDir` is `$root/plans/$slug/`
- [ ] Creates worktree when not already in one
- [ ] Exits 1 with error message when not in worktree and no branch given
- [ ] Tests pass: `bats scripts/bin/ai/plan/__tests__/plan-start.bats`
