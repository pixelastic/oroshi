## Issue 02 — refactor ralph-single

### Standards: "Dead mock.zsh construction in setup()"

```bash
printf "source '%s'\n" "$script" >"$BATS_TMP_DIR/mock.zsh"
```

**Problem:** Reviewer claimed `mock.zsh` has no consumer after `CURRENT`/`caller.zsh` was removed, making the `printf` dead setup code.
**Reason skipped:** Finding is incorrect. `mock.zsh` is the file `bats_mock` appends to (`declare -f "$@" >> "$MOCK_OVERRIDE"`), and `zshenv-guest.zsh` sources it for every `bats_run_zsh` subprocess. The `printf` seeds it with `source 'ralph-single.zsh'` so the function is defined in the subprocess — without it all tests would fail with "command not found".

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
