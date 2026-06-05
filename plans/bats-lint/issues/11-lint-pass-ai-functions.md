## TLDR

Lint pass on AI autoload function tests (2 files).

## What to build

Run `bats-lint` on `claude-terminal-fix.bats` and `rtk-can-rewrite.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on both files
- [ ] `bats` passes on both files
- [ ] Developer review sign-off
