## Issue 02 — Session scripts
### `return 1` in standalone script
```zsh
return 1
```
**Problem:** Reviewer flagged `return 1` as incorrect in a standalone script with `set -e` (should be `exit 1`).
**Reason skipped:** The reference implementation `slack-writer-end` uses the same `return 1` pattern — this is an established codebase convention for ZSH scripts that are sourced, not executed as subprocesses.
