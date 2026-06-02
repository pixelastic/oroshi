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
