## Issue 01 — kitty-helper-claude-start

### `local` at script top-level flagged as hard violation

```zsh
local projectRoot="$(git-directory-root)"
local prompt="$1"
```

**Problem:** Reviewer flagged `local` at script top-level as invalid in zsh (only valid inside functions).

**Reason skipped:** In zsh, `local` IS valid at the top-level of a script — the script body is treated as an implicit function scope. This is an established codebase pattern present in `kitty-window-toggle-claude` and other kitty bin scripts. The deleted `kitty-run-claude` used the same pattern intentionally.
