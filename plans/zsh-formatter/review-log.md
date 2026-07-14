## Issue 01 — Rewrite zsh-fix with beautysh
### Fixture extension .zsh → .txt
```
fixture-formatted.txt  (spec says fixture-formatted.zsh)
```
**Problem:** Spec requires `fixture-formatted.zsh` but implementation uses `.txt`
**Reason skipped:** `.zsh` extension triggers zshlint on fixture content (`case "$1"` → noManualArgParsing violation). Both fixtures use `.txt` to avoid linter and lint-staged interference.

### ZSH-specific byte-identical assertion not explicit
```bats
[[ "$output" == "$expected" ]]
```
**Problem:** No explicit assertion that ZSH-specific lines are byte-identical before/after formatting
**Reason skipped:** Whole-output equality already covers this — if any ZSH syntax changed, the assertion would fail. A separate assertion would be redundant.

## Issue 02 — Multi-file support
### `return 1` vs `exit 1` in script
```zsh
return 1
```
**Problem:** Script uses `return 1` instead of `exit 1` under `set -e`
**Reason skipped:** Pre-existing pattern — all other early exits in the file use `return`. Changing only this one would be inconsistent.

### Missing guard comments on test assertions
```bats
[[ "$output" != "" ]]
```
**Problem:** No comment explaining what output is expected
**Reason skipped:** Guard-comment convention applies to production code conditions, not test assertions where the `@test` title describes the expectation.
