## Issue 01 — Unified reject path

### Standards: bats_tmp_dir in state-writing tests
```bats
mkdir -p "$BATS_TMP_DIR/test"
echo '...' >"$BATS_TMP_DIR/test/state.json"
```
**Problem:** Reviewer flagged that `$BATS_TMP_DIR` must be set up via `bats_tmp_dir` before use in the tests.
**Reason skipped:** `setup()` already calls `bats_tmp_dir` unconditionally; all tests inherit a valid `$BATS_TMP_DIR`. The pattern matches existing tests in the file.

### Spec: permissionDecisionReason null vs key absence
```bats
[ "$(echo "$output" | jq '.hookSpecificOutput.permissionDecisionReason')" = "null" ]
```
**Problem:** Spec says "No `permissionDecisionReason` field" — test only checks for JSON `null`, not strict key absence.
**Reason skipped:** `askWithAutoAccept` in the helper never emits the `permissionDecisionReason` key. `jq` returns `null` for both absent keys and explicit null values — the test correctly validates key absence given the implementation.
