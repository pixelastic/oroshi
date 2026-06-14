## TLDR

Replace the inline lock file check in `ralph-single` with a call to `ralph-is-running`.

## What to build

In `ralph/__lib/ralph-single.zsh`, replace the inline guard:

```
if [[ -f "$dir/ralph.json" ]]; then
  local existingMode="$(ralph-state "$dir" get mode)"
  if [[ "$existingMode" == "single" ]]; then
    ...
  fi
fi
```

with a call to `ralph-is-running "$dir"`.

**Behavior change:** the refactored guard blocks on any active session (any mode), not just `mode=single`. This means if a loop session is already running in that plan dir, `ralph-single` will also refuse to start. This is intentional.

Update `ralph-single.bats` accordingly: the existing test "proceeds normally when ralph.json exists with mode=loop" becomes "blocks when ralph.json exists with mode=loop".

## Scaffolding Tests

The inline guard is replaced by a delegation to `ralph-is-running`. No new behavior is introduced beyond the mode-widening described above — the scaffolding change is verified by the updated test suite.

## Acceptance criteria

- [ ] `ralph-single` uses `ralph-is-running "$dir"` instead of the inline file check
- [ ] `ralph-single` still refuses to run when a single session is active
- [ ] `ralph-single` now also refuses when a loop session is active
- [ ] `ralph-single.bats` updated — loop-mode test reflects new blocking behavior
- [ ] All existing `ralph-single.bats` tests pass (with the loop-mode update)
- [ ] Linting passes
