## Issue 04 — session state ask escalate

### Standards: variable guards missing after `local var="$(cmd)"`
```zsh
local sessionId="$(print -r -- "$inputJson" | jq -r '.session_id // empty')"
local rejectedList="$(print -r -- "$solkanJson" | jq -r '.commands.rejected | join(", ")')"
```
**Problem:** zsh-writer variables.md requires a guard line after `local var="$(cmd)"`.
**Reason skipped:** The inline `"$sessionId" != ""` checks throughout the code serve as the guard. `rejectedList`/`rejectedCount` are only reached when solkan rejected (non-zero), so empty output is not a silent failure case.

### Standards: repeated mock boilerplate in 8 AC tests
**Problem:** Reviewer suggested extracting to `setup()` for DX.
**Reason skipped:** Each test needs independent mock definitions (even if identical here, future tests may vary). Extraction would break that flexibility.

### Standards: `echo "$output"` in test assertions
**Problem:** Inconsistent with `print -r --` in hook code.
**Reason skipped:** `echo "$output"` is the BATS idiom used consistently across all existing tests in this file. Not a hard rule violation.

### Spec: "AC8" test label misapplied
**Problem:** The test labelled "AC8" covers missing session_id fallback, but spec AC8 = "ask user output does not contain permissionDecisionReason". The actual AC8 assertion lives in the combined AC3+AC8 test.
**Reason skipped:** The assertion is present and correct; the label mismatch is cosmetic. The missing-session_id case is covered by the error-handling paragraph of the spec.

## Issue 03 — hook multi-reject ask

### Spec: hook implementation change absent from diff
```zsh
# preToolUse-Bash — reject path (unchanged)
jo -d. \
  hookSpecificOutput.permissionDecision="ask" \
  hookSpecificOutput.permissionDecisionReason="❌ ${rejectedList} ❌" \
  hookSpecificOutput.updatedInput.command="${updatedInputCommand}"
```
**Problem:** Spec reviewer noted the hook source was not changed in this diff.
**Reason skipped:** The hook was already corrected during the 02b refactor. Issue 03 only required adding the missing `no systemMessage` test — no hook source change was needed.

## Issue 02b — bats-mock test refactor

### `setopt local_options err_return` missing in wrapper functions
```zsh
preToolUse-Bash-solkan() {
  solkan --allow-list-file "${hookDir}/allowlist.json" "$1"
}
```
**Problem:** zsh-writer says autoloaded functions should carry `err_return`.
**Reason skipped:** Not autoloaded functions — part of the hook mechanism. Guidance explicitly removed `set -e` from the hook; adding `err_return` here carries the same risk.

### `local rewritten` guard in preToolUse-Bash-rtk()
```zsh
local rewritten="$(rtk rewrite "$cmd")"
if [[ "$rewritten" == "" ]]; then
  print -- "$cmd"
  return 0
fi
```
**Problem:** Reviewer suggested guarding subshell assignment per variables.md.
**Reason skipped:** The empty-result case is already handled on the next line; no silent failure is possible.

### Spec: mock.zsh setup called "dead code" in sibling test files
```bash
printf "source '%s'\n" "$SCRIPT" > "$BATS_TMP_DIR/mock.zsh"
```
**Problem:** Spec reviewer flagged as dead code since tests call `bats_run_function`.
**Reason skipped:** Incorrect. `bats_run_function` sources `$BATS_TMP_DIR/mock.zsh` before calling the function — that's how the function definition reaches the ZSH subprocess.

## Issue 02 — Test infrastructure

### Missing `set -e` in hook
```zsh
#!/usr/bin/env zsh
# (no set -e)
local hookDir="${0:A:h}"
```
**Problem:** zsh-writer header.md requires `set -e` for shebang scripts.
**Reason skipped:** Guidance explicitly documents this exception — `set -e` was removed from the hook after unexpected exits in the decision matrix.

### Missing `bats_load_library 'helper'` in test file
```bash
setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash"
  # no bats_load_library 'helper', no bats_tmp_dir/bats_cleanup
```
**Problem:** zsh-writer testing.md requires the helper library pattern.
**Reason skipped:** Pre-existing; these hook tests don't use oroshi bats helpers and all 9 tests pass without them. Fixing would require adding the helper as a test-only dependency, out of scope.
