## TLDR

Delete old skills and scripts, update grill-me to reference `/plan`.

## What to build

Delete:
- `tools/ai/claude/config/skills/prd/` (SKILL.md + references/)
- `tools/ai/claude/config/skills/issues/` (SKILL.md + references/)
- `scripts/bin/ai/prd/` (prd-end + tests)

Update `tools/ai/claude/config/skills/grill-me/SKILL.md`:
- Replace `/prd` with `/plan`
- Reorder: `/plan` first, `/glossary` second, `/quick-implementation` third

## Acceptance criteria

- [ ] `tools/ai/claude/config/skills/prd/` deleted
- [ ] `tools/ai/claude/config/skills/issues/` deleted
- [ ] `scripts/bin/ai/prd/` deleted
- [ ] grill-me lists `/plan` as option 1
- [ ] grill-me no longer references `/prd`
- [ ] No remaining references to `/prd` or `/issues` as invocable skills in the repo
