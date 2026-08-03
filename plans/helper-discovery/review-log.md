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
