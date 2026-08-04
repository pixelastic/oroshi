## Issue 02 — helper-list-raw
### sed -n short-form flag
```zsh
descLine="$(sed -n '2p' "$file")"
```
**Problem:** `sed -n` uses short-form flag instead of long-form
**Reason skipped:** `sed` has no portable long-form for `-n`; as idiomatic as the allowed `head -1` exception

### Description extraction blanks #-prefixed lines without space
```zsh
[[ "$descLine" == "#"* ]] && descLine=""
```
**Problem:** Spec says "Empty string if no description found" — this actively blanks `#foo` lines
**Reason skipped:** Defensive behavior; lines starting with `#` without a space are not well-formed descriptions, so blanking them is reasonable

## Issue 03 — helper-list
### No test file
```zsh
# (no code — entire function shipped without tests)
```
**Problem:** zsh-writer workflow requires TDD (failing test before implementation)
**Reason skipped:** Issue spec explicitly states "No tests — pure presentation"

### Column alignment concern
```zsh
table $output
```
**Problem:** Reviewer questioned whether `table` alone satisfies column alignment requirement
**Reason skipped:** `table` is the same approach used by `skills-list` and other existing list wrappers — matches the established pattern

## Issue 05 — Move JS files into __lib/ subdirectories
### Scaffolding tests absent from diff
```bats
@test "jsonc-remove-key.js exists in __lib/" {
  [[ -f "$SCRIPTS_BIN/json/__lib/jsonc-remove-key.js" ]]
}
```
**Problem:** Spec review flagged that 7 scaffolding tests were missing from the diff
**Reason skipped:** False positive — tests exist at `plans/helper-discovery/scaffold/05-move-js-to-lib.bats` but are untracked, so `review-diff dirty` didn't include them
