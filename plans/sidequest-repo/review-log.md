## Issue 02 — Rewrite sidequest filepath

### Standards: local before set -e
```zsh
set -e

local filepath="$1"
```
**Problem:** Reviewer claimed `local filepath="$1"` appeared before `set -e`.
**Reason skipped:** False positive. `set -e` is on line 5; `local filepath` is on line 7. Order is correct.

### Spec: --no-focus not explicitly passed
```zsh
kitty-tab-create \
	"$slug" \
	--cwd "$worktreePath" \
	--cmd "kitty-helper-claude-start @$filepath"
```
**Problem:** Reviewer flagged that `--no-focus` is not passed to `kitty-tab-create`, suggesting the tab might steal focus.
**Reason skipped:** False positive. Spec acceptance criterion says "no `--focus`" (flag must be absent), and explicitly states "The `--focus`/`--no-focus` flags are removed." Omitting both flags is the correct implementation.
