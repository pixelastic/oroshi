## Issue 01 — \xa0 regression test

### Standards findings on pre-existing plan files

**Problem:** Reviewer flagged absolute paths (`~/.oroshi/...`) in GUIDANCE.md and issue files, plus missing `## Scaffolding Tests` section in issue files.
**Reason skipped:** All flagged files are pre-existing plan artifacts, not changed in this session. Path format in GUIDANCE.md is intentional — the test target lives in a separate repo (`~/.oroshi/`) and absolute paths are needed for clarity.

### Spec review — empty diff

**Problem:** Spec agent reported "nothing implemented" because `review-diff dirty` returned empty output.
**Reason skipped:** Expected behavior — the test was added to `~/.oroshi/` (separate git repo), invisible to `review-diff` in this worktree. Spec compliance was verified manually.

## Issue 02 — mock print -r fix

### $OROSHI_ROOT in GUIDANCE.md

```
~/.oroshi/tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats
```

**Problem:** Standards flagged `~/.oroshi/` paths in GUIDANCE.md violating the `$OROSHI_ROOT` convention.
**Reason skipped:** The rule targets production code that gets sourced by ZSH. GUIDANCE.md paths are human/agent navigation aids in plan documentation — never executed. Out of scope.
