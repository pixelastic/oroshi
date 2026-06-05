## TLDR

Lint pass on theming and prompt tests (3 files).

## What to build

Run `bats-lint` on `projects-build.bats`, `git.bats`, `index.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 3 files
- [ ] `bats` passes on all 3 files
- [ ] Developer review sign-off
