## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90001: detect `local` declarations that define multiple
variables on one line (e.g. `local a b c` or `local raw="" line="" path=""`).

**Before writing any code**, run a `grill-with-docs` session with the user to
confirm exactly which `local` forms should and should not trigger the rule,
including edge cases such as `local -a arr`, `local -r VAR=...`, and array
literals with spaces inside parentheses.

Function: `zshlintRule_noGroupedLocals(file)`
Level: `warning`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags `local a b c` and `local a="" b=""` style declarations
- [ ] Function does not flag single-variable `local` with flags (`local -a arr`, `local -r VAR=val`)
- [ ] Function does not flag comment lines
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
