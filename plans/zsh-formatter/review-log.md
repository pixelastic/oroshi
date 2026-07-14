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
