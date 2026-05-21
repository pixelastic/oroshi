## PRD

[PRD.md](./PRD.md)

## What to build

A new script `ralph-progress` in the ralph domain (`scripts/bin/ai/ralph/`), sibling of `ralph-end`. Takes an optional directory argument (the ralph prd dir containing `prd.json`); if omitted, calls `ralph-directory` to deduce it from context.

Reads `prd.json` with `jq` and outputs `done▮total` on stdout, where `total` is the array length and `done` is the count of items where `passes == true` (boolean strict). The icon used in display is defined as a local variable at the top of any caller function (not in this script — this script only outputs data).

Exits 1 if: `prd.json` is missing, unreadable, not a valid JSON array, or the array is empty.

`ralph-end` is updated to use `ralph-progress` instead of its inline jq call, fixing the `status != "complete"` → `passes == true` discrepancy.

Bats tests use temporary git worktrees with fixture `prd.json` files. Covers: mixed passes, all true, all false, empty array (exit 1), malformed JSON (exit 1), missing file (exit 1), no argument (deduced from worktree context via `ralph-directory`).

## Acceptance criteria

- [ ] Outputs `done▮total` for a valid prd.json with mixed `passes` values
- [ ] Counts only entries where `passes == true` (boolean strict; `null` and missing count as false)
- [ ] Exits 1 for empty array `[]`
- [ ] Exits 1 for malformed JSON
- [ ] Exits 1 when `prd.json` is missing
- [ ] Works with no argument by calling `ralph-directory` to find the prd dir
- [ ] `ralph-end` uses `ralph-progress` and correctly detects PRD completion
- [ ] All bats tests pass

## Blocked by

- issue-003-ralph-directory.md
