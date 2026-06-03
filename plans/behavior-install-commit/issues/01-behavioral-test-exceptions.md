## TLDR

Add an Exceptions section to behavioral-tests.md for code categories that can't have behavioral tests.

## What to build

Add a new `## Exceptions` section to the behavioral tests reference, placed immediately after the pivot question block (before `## Definition`). This section acts as a short-circuit: if the issue matches an exception category, skip behavioral tests and use scaffolding tests exclusively.

Two exception categories:

1. **Installation scripts** — install tools globally on the machine (apt, wget + mv to ~/local/bin/, etc.). Network, sudo, and disk writes are unmockable in the test harness.
2. **Pre-commit / lint-staged wiring** — lint, test, or validation hooks triggered only during a real `git commit`. Simulating a full commit in BATS is unrealistic.

## Acceptance criteria

- [ ] `## Exceptions` section exists in behavioral-tests.md
- [ ] Section is placed between the pivot question and `## Definition`
- [ ] Both categories are listed: installation scripts, pre-commit/lint-staged wiring
- [ ] Each category states why behavioral tests are impossible
- [ ] Section directs the agent to use scaffolding tests instead
