## TLDR

Remove all ralph.json lock logic from `ralph-start` — it becomes a pure issue-selection utility.

## What to build

Strip `ralph-start` of its session awareness: remove the check for an existing `ralph.json` with `mode=single`, and remove the `ralph-state init single` call. After this issue, `ralph-start` resolves a plan directory, reads `state.json`, finds the next eligible issue, and returns JSON — nothing more.

Update `ralph-start.bats` to remove all tests that assert on ralph.json creation or session lock behavior.

## Behavioral Tests

**Issue selection (unchanged behavior):**
- returns `status: finished` when all issues are done
- returns `status: deadlocked` when remaining issues are all blocked
- returns `status: ready` with correct issue path when an eligible issue exists
- skips issues whose blockers are not yet done
- picks the lowest-id eligible issue when multiple are available

## Acceptance criteria

- [ ] `ralph-start` contains no reference to `ralph.json` or `ralph-state`
- [ ] `ralph-start.bats` contains no tests asserting on ralph.json
- [ ] All remaining `ralph-start.bats` tests pass
