# Wave Checkpoint Template

Use this template to write the checkpoint issue for `reduce` and `rewrite` waves.

## Issue content

```markdown
## TLDR

Wave checkpoint — triage bugs, then launch the next wave.

## What to do

1. Read GUIDANCE.md `## Bugs found` for all bugs cataloged during this wave.
2. For each bug, ask the user to choose:
   - **fix now** — create a bug-fix issue and add it to the plan. The bug-fix issue must include removing the bug entry from GUIDANCE.md `## Bugs found` after the fix.
   - **fix later** — real bug, not now. Keep it in GUIDANCE.md for the next wave's checkpoint.
   - **dismiss** — not a real bug. Remove it from GUIDANCE.md `## Bugs found`.
3. Once all bugs are triaged, run `/refactor <next-wave>` to launch the next wave. The next wave appends its issues after the bug-fix issues.
```

Replace `<next-wave>` with `rewrite` (after reduce) or `restructure` (after rewrite).
