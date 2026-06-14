## Issue 01 — ralph-is-running

### `return` vs `exit` in shebang script

```zsh
[[ "$wtRoot" == "" ]] && return 1
```

**Problem:** Standards agent flagged `return` as wrong for bin scripts; said `exit` should be used instead.
**Reason skipped:** `return` at top-level of a zsh script is equivalent to `exit` by zsh spec. Consistent with existing bin scripts in this repo (`plan-directory`, `ralph-state`) which also use `return`. No functional difference.

### `[ ]` vs `[[ ]]` in test assertions

```bash
[ "$status" -eq 1 ]
```

**Problem:** Standards agent noted inconsistency with documented style that uses `[[ ]]`.
**Reason skipped:** Consistent with `ralph-state.bats` which uses `[ ]` throughout. No functional difference; not a hard rule in the codebase.
