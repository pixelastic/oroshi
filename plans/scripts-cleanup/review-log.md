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

## Issue 03 — missingDocComment lint rule
### Spec says `__tests/` vs code `__tests__/`
```
Skip files in __lib/, __rules/, __tests/ directories
```
**Problem:** Spec uses `__tests/` (single trailing underscore) but implementation checks `__tests__/` (double).
**Reason skipped:** Codebase convention is `__tests__/` (double underscore). Spec typo, not a real discrepancy.
