## Issue 02 — ralph + to-issues behavioral terminology

### Standards: `AC` acronym undefined in issues-XX-slug.md
**Problem:** "AC" used without definition in the template.
**Reason skipped:** "AC" (Acceptance Criterion) is used throughout all existing issue files and GUIDANCE.md in the project; agents working with these files already know the term.

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
