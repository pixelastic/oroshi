## Issue 02 — Rename script sidequest-end

### `local` used at script top-level
```zsh
local file="$1"
```
**Problem:** `local` has no effect outside a function; pre-existing in `handoff-end`.
**Reason skipped:** zshlint does not flag it; pre-existing pattern carried over verbatim.

### Spec Modules 1, 3, 4 absent
**Problem:** Spec agent flagged missing skill rename, whitelist settings, CLAUDE.md update.
**Reason skipped:** All three belong to other issues (01 already done, 03 pending). Issue 02 scope is script rename only.
