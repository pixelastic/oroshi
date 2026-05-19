## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90003: detect use of `$(basename ...)`, `$(dirname ...)`,
or `$(realpath ...)` as subshell calls. ZSH modifiers (`:t`, `:h`, `:a`) are
the preferred alternative.

**Before writing any code**, run a `/grill-me` session with the user to
confirm edge cases, particularly these commands appearing in comments or in
`echo` strings for documentation purposes.

Function: `zshlintRule_noExternalBasename(file)`
Level: `style`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags `$(basename ...)`, `$(dirname ...)`, `$(realpath ...)`
- [ ] Function does not flag these words in comment lines
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
