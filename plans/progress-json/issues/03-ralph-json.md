## PRD

plans/progress-json/PRD.md

## What to build

Update `ralph-state` to use `ralph.json` instead of `.ralph-state.json` as the state filename. The file is no longer hidden (no dot prefix), making it easier to see and edit manually.

The command interface stays identical: `ralph-state <dir> init|get|set|clear`. Only the internal filename changes.

Add `ralph.json` to the repo's `.gitignore` so it's never tracked.

Update bats tests to verify the new filename.

## Acceptance criteria

- [ ] `ralph-state` reads/writes `ralph.json` instead of `.ralph-state.json`
- [ ] `ralph.json` is in `.gitignore`
- [ ] All `ralph-state` bats tests pass with the new filename
- [ ] `init` creates `ralph.json` with `{ mode, done: false, prd_done: false }`

## Blocked by

None — can start immediately
