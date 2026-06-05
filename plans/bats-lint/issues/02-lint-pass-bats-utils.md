## TLDR

Lint pass on bats utility tests (1 file).

## What to build

Run `bats-lint` on `bats-test-path.bats`. For each violation, decide: fix, exception, or new rule.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on the file

**Tests still pass:**
- `bats` exits 0 on the file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on `bats-test-path.bats`
- [ ] `bats` passes on the file
- [ ] Developer review sign-off
