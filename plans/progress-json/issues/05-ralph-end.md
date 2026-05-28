Update `ralph-end` to use `ralph.json` and `plans-progress` instead of the old file names.

## What to build

Update `ralph-end` to work with the new file layout:

1. Use `ralph-state` (which now reads `ralph.json`) — no direct file manipulation
2. Use `plans-progress` (instead of `ralph-progress`) to check if all issues are done
3. Do NOT modify state.json — the ralph skill handles that

The logic stays the same: skip if single mode, set `done: true`, check if all issues complete to set `prd_done: true`.

Update bats tests.

## Acceptance criteria

- [ ] `ralph-end` sets `done: true` in `ralph.json` via `ralph-state`
- [ ] Sets `prd_done: true` when `plans-progress` reports all done
- [ ] Does not touch state.json
- [ ] Skips silently in single mode
- [ ] Bats tests pass

## Blocked by

- 02 (needs `plans-progress`)
- 03 (needs `ralph-state` with `ralph.json`)
