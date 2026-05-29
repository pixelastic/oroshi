## Issue 01 — test-git-branch-list-raw

### Spec reviewer: `NF-1 -eq 7` should be `-eq 6`
```bash
count="$(awk -F'▮' '{print NF-1}' <<< "$line")"
[ "$count" -eq 7 ]
```
**Problem:** Reviewer argued 7 fields → 6 separators → `-eq 6`.
**Reason skipped:** Format terminates each field with `▮` (not separates). 7 fields → 7 `▮` terminators → `NF=8` in awk → `NF-1=7`. Correct.

### Spec reviewer: shape assertions weaker than fixture data
**Problem:** Tests check generic format shape rather than exact output values like worktree tests do.
**Reason skipped:** Issue 01 explicitly locks down format shape (field count, non-empty checks). Fixture-level assertions are out of scope for a regression-guard issue.
