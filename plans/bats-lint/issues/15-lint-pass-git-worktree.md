## TLDR

Lint pass on git worktree tests (14 files).

## What to build

Run `bats-lint` on all git-worktree-* test files plus `git-worktree-list-raw.bats` from scripts/bin. Fix violations or encode rules.

Files: git-worktree-create, delete, distance, distance-raw, has-plan, is-ahead, is-behind, list, list-raw, main, name, path, pull, push, start, switch (plus scripts/bin version of list-raw).

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 14 files
- [ ] `bats` passes on all 14 files
- [ ] Developer review sign-off
