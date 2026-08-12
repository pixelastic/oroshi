## Issue 02 — Session scripts
### `return 1` in standalone script
```zsh
return 1
```
**Problem:** Reviewer flagged `return 1` as incorrect in a standalone script with `set -e` (should be `exit 1`).
**Reason skipped:** The reference implementation `slack-writer-end` uses the same `return 1` pattern — this is an established codebase convention for ZSH scripts that are sourced, not executed as subprocesses.

## Issue 03 — Skill file
### Inline reference material extraction
```markdown
1. **Important first** — inverted pyramid...
2. **Scannable** — use numerals, bullets...
...
1. Venue was adequate (space, seating, AV)
2. Started on time (within 5 min)
...
```
**Problem:** Writing principles, scoring rubric, and output structure are inline rather than extracted to `references/` files.
**Reason skipped:** File is 146 lines, well under the 500-line limit. Extraction adds indirection for no practical gain at this size.
