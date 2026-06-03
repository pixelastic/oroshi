## Issue 01 — Split test-types.md into behavioral-tests.md + scaffolding-tests.md

### `behavioral-tests.md` — `__tests__/` path is JS-specific
```md
Lives in `__tests__/` forever.
```
**Problem:** Hardcodes JS test directory; original said "project's test suite forever."
**Reason skipped:** Issue spec explicitly mandates `__tests__/`.

### Spec agent: new files at "wrong path"
**Problem:** Agent claimed files landed outside the repo.
**Reason skipped:** False positive — agent misread absolute worktree paths in diff output. Files confirmed at `tools/ai/claude/config/skills/tdd/references/`.
