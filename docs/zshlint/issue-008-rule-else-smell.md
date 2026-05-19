## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement Custom Rule 90007: detect `else` blocks as a prompt to consider the
return-early pattern. This rule has a higher false positive rate than others
and is intentionally at `warning` level.

**Before writing any code**, run a `/grill-me` session with the user to
agree on exactly what constitutes a flaggable `else` (standalone `else` on its
own line), confirm the acceptable false positive rate, and decide whether
`elif` should also be flagged.

Function: `zshlintRule_elseSmell(file)`
Level: `warning`

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases and acceptable FP rate documented
- [ ] Lib File created in `__rules/`
- [ ] Function flags standalone `else` on its own line
- [ ] Function does not flag `else` inside strings or comments
- [ ] bats test file created in `__tests__/`, all tests pass
- [ ] Rule wired into Orchestrator static list

## Blocked by

- [issue-002 — Orchestrator scaffold](./issue-002-orchestrator-scaffold.md)
