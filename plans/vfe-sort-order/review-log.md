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
