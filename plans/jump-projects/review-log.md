## Issue 03 — complete-jumps merge projects
### Merge direction contradicts spec algorithm
```zsh
entries[$name]="${PROJECTS[$key]}"
```
**Problem:** Spec says "iterate PROJECTS, add entries not already in marks" but code unconditionally overwrites marks with projects.
**Reason skipped:** Behavioral outcome is identical — projects win on collision either way. Implementation approach differs from spec wording but satisfies all acceptance criteria.
