## Issue 01 — migrate languages domain
### pip-list-raw function keyword
```zsh
function getRawPackages()
```
**Problem:** Named function inside autoloaded function leaks into global scope
**Reason skipped:** Pre-existing pattern, not introduced by this diff — out of scope for a move operation

### pip-package-colorize flag test style
```zsh
[[ "$isWithIcon" != 1 ]]
```
**Problem:** Uses `!= 1` instead of `== "1"` per flag test convention
**Reason skipped:** Pre-existing, not introduced by this diff — out of scope for a move operation

## Issue 02 — js-test-path
### Single vs double bracket assertions in bats
```bats
[ "$status" -eq 0 ]
```
**Problem:** Reviewer flagged `[ ]` vs `[[ ]]` in test assertions
**Reason skipped:** Existing `bats-test-path.bats` reference uses `[ ]` consistently — established convention

## Issue 04 — git-file-edit sort
### Test setup duplication
```bash
filetypes-load-definitions() { :; }
filetypes-group() { REPLY="script"; }
test-path() { ... }
nvim() { shift; printf '%s\n' "$@"; }
bats_mock filetypes-load-definitions filetypes-group test-path nvim
```
**Problem:** Mock definitions are copy-pasted across 6 tests instead of extracted into a helper
**Reason skipped:** Existing tests in the same file follow the same inline pattern; out of scope

### Test setup comments
```bash
@test "sorts source before its test when both are dirty" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
```
**Problem:** Multi-step setup blocks have no explanatory comments
**Reason skipped:** Existing tests in the same file follow the same uncommented pattern; consistency
