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

## Issue 03b — bin-zsh dispatcher
### Call-site migration not performed
**Problem:** Spec requires updating callers in NeoVim, Kitty, Ubuntu keybindings, Argos to use `bin-zsh <function>`.
**Reason skipped:** Repo-wide grep found zero references to `colorize-bin` or `git-directory-root-bin` outside plan docs — callers already removed in prior commit (ac086c2ab). Nothing to migrate.

### Broader -bin grep not evidenced
**Problem:** Spec asks to grep for any other `-bin` scripts beyond the two named.
**Reason skipped:** `find` + `grep` were both run during implementation — only `colorize-bin` and `git-directory-root-bin` existed. No gap.

## Issue 04 — Domain audio
### base64 short-form flag in Argos configs
```zsh
local image=$(cat $iconPath | base64 -w 0)
```
**Problem:** `base64 -w 0` uses short-form flag instead of `--wrap=0` per calling-commands convention.
**Reason skipped:** Line not modified in this diff — only surrounding lines changed. Argos config widgets are not core zsh functions; borderline scope for the long-form convention.
