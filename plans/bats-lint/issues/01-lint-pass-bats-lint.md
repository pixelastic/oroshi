## TLDR

Lint pass on the bats-lint test suite itself (5 files) — the meta domain.

## What to build

Run `bats-lint` on all 5 files in the bats-lint domain (core tests + rule tests). For each violation, decide collaboratively: fix the code, add a justified exception, or introduce a new custom rule. Any new rule ships with its test file and fixtures in the same session.

Files in scope:
- bats-lint core tests (3 files)
- rule-no-run-zsh test (1 file)
- rule-no-inline-function test (1 file)

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file in the domain

**Tests still pass:**
- `bats` exits 0 on each file in the domain

**New rules (if any):**
- Rule detects the target violation pattern
- Rule ignores clean code

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 5 files
- [ ] `bats` passes on all 5 files
- [ ] Each violation decision documented (fix / exception / new rule)
- [ ] Any new rule has a test file + fixtures
- [ ] Developer review sign-off
