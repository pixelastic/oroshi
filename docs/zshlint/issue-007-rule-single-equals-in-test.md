## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90006: detect `=` used instead of `==` for string comparison
inside `[[ ]]` blocks. Both are valid ZSH but `==` is the project convention.

**Before writing any code**, run a `/grill-me` session with the user to
confirm the regex handles edge cases: `!=`, `<=`, `>=`, `=~` must not be flagged;
variable assignments after `]]` on the same line must not be flagged.

Function: `zshlintRule_singleEqualsInTest(file)`
Level: `style`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags `[[ "$foo" = "bar" ]]`
- [ ] Function does not flag `!=`, `<=`, `>=`, `=~`
- [ ] Function does not flag variable assignments on the same line after `]]`
- [ ] Function does not flag comment lines
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
