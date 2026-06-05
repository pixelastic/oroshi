## TLDR

Lint pass on AI script tests — ralph, review, prd (9 files).

## What to build

Run `bats-lint` on: `prd-end.bats`, `plan-directory.bats`, `plan-progress.bats`, `ralph.bats`, `ralph-end.bats`, `ralph-start.bats`, `ralph-state.bats`, `review.bats`, `review-diff.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 9 files
- [ ] `bats` passes on all 9 files
- [ ] Developer review sign-off
