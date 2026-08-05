## Issue 02 — Rules, glossary, naming
### domain-action segment count ambiguity
```markdown
Naming: `domain-action` pattern (e.g. `git-commit-cancel`, `png-alpha`)
```
**Problem:** `domain-action` could be misread as strictly two segments, but rename map has 3-segment names like `png-add-alpha`.
**Reason skipped:** The examples already include `git-commit-cancel` (3 segments). `domain-action` means "domain followed by action words", not "exactly two hyphenated tokens".

### User confirmation of rename map
**Problem:** Acceptance criterion "User confirmed rename map" not yet met.
**Reason skipped:** Process step — user confirms when reviewing changes before committing. Outside ralph's scope.
