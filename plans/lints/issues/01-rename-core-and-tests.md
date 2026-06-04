## TLDR

Rename all zshlint scripts, internals, and test files to zsh-lint in one atomic pass so the test suite stays green throughout.

## What to build

Rename the directory `scripts/bin/zsh/zshlint/` to `scripts/bin/zsh/zsh-lint/` and the three scripts within it (`zshlint` → `zsh-lint`, `zshlint-shellcheck` → `zsh-lint-shellcheck`, `zshlint-custom` → `zsh-lint-custom`).

Update all internals in the same pass:
- The orchestrator's internal variable names that reference the sub-linters
- The rule function prefix: `zshlintRule_*` → `zshLintRule_*` in all 12 rule files and in `zsh-lint-custom`
- The suppression comment syntax: `# zshlint-disable` → `# zsh-lint-disable` in the parser, in rule file examples, and in BATS fixtures

Rename the three orchestrator-level BATS files (`zshlint.bats`, `zshlint-custom.bats`, `zshlint-shellcheck.bats`) and update all internal path/variable references within them. Update the hardcoded path fixture in `bats-test-path.bats` to point to the new directory.

The goal is that after this issue, `rtk bats` passes on the full `zsh-lint` suite.

## Scaffolding Tests

- No file or directory named `zshlint` exists anywhere under `scripts/bin/zsh/`
- The three scripts exist at their new paths under `scripts/bin/zsh/zsh-lint/`
- No function named `zshlintRule_*` exists in any rule file
- No occurrence of `# zshlint-disable` remains in any source or test file

## Behavioral Tests

**Suppression:**
- `# zsh-lint-disable <code>` on the line above a violation suppresses it
- `# zshlint-disable <code>` (old syntax) does NOT suppress a violation
- `# zsh-lint-disable wrongCode` does not suppress a different rule's violation

**Orchestrator:**
- `zsh-lint` merges output from `zsh-lint-shellcheck` and `zsh-lint-custom` into one JSON array
- `zsh-lint` exits 1 when either sub-linter finds violations
- `zsh-lint` exits 0 when no violations are found

## Acceptance criteria

- [ ] Directory renamed to `scripts/bin/zsh/zsh-lint/`
- [ ] Scripts renamed: `zsh-lint`, `zsh-lint-shellcheck`, `zsh-lint-custom`
- [ ] All 12 rule functions use `zshLintRule_*` prefix
- [ ] Suppression parser matches `# zsh-lint-disable`
- [ ] All BATS files renamed and paths updated internally
- [ ] `bats-test-path.bats` fixture paths updated
- [ ] `rtk bats` passes on the full suite
