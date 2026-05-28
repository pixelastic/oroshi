## PRD

plans/progress-json/PRD.md

## What to build

Rename `ralph-progress` to `plans-progress`. The script outputs `done▮total` for a plan directory.

Two changes beyond the rename:
1. Read `state.json` instead of `issues.json`
2. Count entries where `.done == true` instead of `.passes == true`

The output format stays identical: `done▮total` with the UTF-8 separator.

Update bats tests: rename the test file, update fixture JSON to use the new state.json schema (`{ id, issue, done, blocked_by }` instead of `{ id, description, steps, passes }`).

## Acceptance criteria

- [ ] `plans-progress` exists and reads `state.json` from the plan directory
- [ ] `ralph-progress` is removed
- [ ] Output is `done▮total` counting `.done == true` entries
- [ ] Returns 1 if state.json is missing or malformed
- [ ] Bats tests pass with new schema fixtures

## Blocked by

- 01 (needs `plans-directory` for path resolution)
