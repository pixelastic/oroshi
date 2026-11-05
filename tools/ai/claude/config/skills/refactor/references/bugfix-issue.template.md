# Bug-fix Issue Template

Use this template when creating a bug-fix issue from the checkpoint triage.

## Issue content

```markdown
## TLDR

Fix bug: <short bug description from GUIDANCE.md>

## What to build

<Reproduce and fix the bug described below.>

## Bug

<Copy the bug entry from GUIDANCE.md `## Bugs found`>

## Before fixing

Grep every caller of the function you touch. Fix the root cause once, in the
shared code, not in each caller.

## Cleanup

After fixing the bug, remove its entry from GUIDANCE.md `## Bugs found`.
```
