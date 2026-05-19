## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90004: detect `while read` loops. ZSH-native `${(f)var}`
iteration is the required alternative.

**Before writing any code**, run a `/grill-me` session with the user to
confirm edge cases: `while true` loops that happen to contain `read` on a later
line, and `readlink` / `readline` which should not match.

Function: `zshlintRule_noWhileRead(file)`
Level: `warning`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags `while IFS= read -r line` and similar `while ... read` patterns
- [ ] Function does not flag `while true` or loops without `read` on the same line
- [ ] Function does not flag `readlink` or `readline`
- [ ] Function does not flag comment lines
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
