## TLDR

Lint pass on misc utility tests (4 files).

## What to build

Run `bats-lint` on `colorize.bats`, `md5.bats`, `simplify-path.bats`, `slugify.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 4 files
- [ ] `bats` passes on all 4 files
- [ ] Developer review sign-off
