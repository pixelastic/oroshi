## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90002: detect `||` chained on a `local` declaration line
(e.g. `local foo="$(cmd)" || return 1`). This is an error because `local` always
returns 0 regardless of the subshell result, making the guard silently ineffective.

**Before writing any code**, run a `grill-with-docs` session with the user to
confirm edge cases, particularly `||` appearing inside the value string itself
(e.g. `local msg="yes || no"`).

Function: `zshlintRule_localOrReturn(file)`
Level: `error`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags `local foo="$(cmd)" || return 1`
- [ ] Function does not flag `||` appearing inside a quoted value
- [ ] Function does not flag comment lines
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
