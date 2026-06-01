## TLDR

Delete `grill-with-docs` skill and the stale docs-naming memory entry.

## What to build

**Delete** the entire `tools/ai/claude/config/skills/grill-with-docs/` folder (contains SKILL.md, CONTEXT-FORMAT.md, ADR-FORMAT.md).

**Delete** the memory file `~/.claude/projects/-home-tim--oroshi/memory/feedback_docs_naming.md` and remove its entry from `MEMORY.md`. This memory documented the `__docs/NAME.md` convention which no longer applies.

## Acceptance criteria

- [ ] `grill-with-docs/` folder is gone
- [ ] `feedback_docs_naming.md` memory file is gone
- [ ] `MEMORY.md` no longer references `feedback_docs_naming.md`
- [ ] No other skill references `grill-with-docs`, `CONTEXT-FORMAT.md`, or `ADR-FORMAT.md`
