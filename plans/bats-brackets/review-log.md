## Issue 01 — noSingleBracket rule
### Mid-line single bracket not detected
```zsh
something && [ "$x" -eq 0 ]
```
**Problem:** Spec reviewer noted mid-line `[ ]` (after `&&`) won't be flagged by the anchored regex
**Reason skipped:** Spec explicitly defines `^[[:space:]]*\[ [^\[]` — anchored to line start by design
