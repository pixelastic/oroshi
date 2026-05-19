## PRD

[ralph --max loop](./PRD.md)

## What to build

A new standalone script `ralph-end` that encapsulates all end-of-session signaling. The ralph skill calls `ralph-end $ARGUMENTS` as the first action of Step 7, before printing the session summary.

`ralph-end <dir>` does two things:
1. Writes `<dir>/.ralph-done` — always, unconditionally. Signals the loop to kill Claude and move on.
2. Reads `<dir>/prd.json` and counts issues whose `status` is not `"complete"`. If count is zero, also writes `<dir>/.ralph-prd-done`. Signals the loop that the PRD is exhausted and no further iterations are needed.

If `prd.json` is absent or unparseable, step 2 is skipped silently — only `.ralph-done` is written.

## Acceptance criteria

- [ ] `ralph-end <dir>` creates `<dir>/.ralph-done`
- [ ] When `prd.json` has at least one issue with `status != "complete"`, `.ralph-prd-done` is NOT created
- [ ] When all issues in `prd.json` have `status == "complete"`, `.ralph-prd-done` IS created
- [ ] When `prd.json` is absent, only `.ralph-done` is created (no error, exit 0)
- [ ] When `prd.json` is malformed JSON, only `.ralph-done` is created (no error, exit 0)
- [ ] The ralph skill Step 7 calls `ralph-end $ARGUMENTS` before printing the session summary
- [ ] All bats tests pass

## Blocked by

None — can start immediately
