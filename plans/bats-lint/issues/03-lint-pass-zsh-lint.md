## TLDR

Lint pass on the zsh-lint test suite (15 files: 3 core + 12 rule tests).

## What to build

Run `bats-lint` on all 15 files in the zsh-lint domain. The 12 rule test files follow a homogeneous pattern — violations found in one likely apply to all. Treat as a single batch.

Files in scope:
- zsh-lint core tests (3 files)
- zsh-lint rule tests (12 files)

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each of the 15 files

**Tests still pass:**
- `bats` exits 0 on each of the 15 files

**New rules (if any):**
- Rule detects the target violation pattern
- Rule ignores clean code

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 15 files
- [ ] `bats` passes on all 15 files
- [ ] Each violation decision documented
- [ ] Any new rule has a test file + fixtures
- [ ] Developer review sign-off
