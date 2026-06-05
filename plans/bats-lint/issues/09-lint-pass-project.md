## TLDR

Lint pass on project/context function tests (6 files).

## What to build

Run `bats-lint` on project tests: `context-badge.bats`, `context-path.bats`, `context-root.bats`, `project-exists.bats`, `project-name.bats`, `project-path.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 6 files
- [ ] `bats` passes on all 6 files
- [ ] Developer review sign-off
