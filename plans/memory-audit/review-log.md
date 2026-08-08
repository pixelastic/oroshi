## Issue 02 — Migrate feedbacks
### Mixed prose+bullet format in Throw-away scripts
```markdown
## Throw-away scripts

Use the `/debug-script` skill when writing complex or multi-step Bash commands.
- DO: Write multi-step debug commands to /tmp/oroshi/claude/scripts/ and run as a single call
```
**Problem:** Section mixes prose intro with bullet list, inconsistent with other sections that are pure bullet lists.
**Reason skipped:** Pre-existing pattern — the prose line was already there before this diff. New bullet follows the `- DO:` convention correctly.
