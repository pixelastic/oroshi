## TLDR

Strip the TDD steps from `skill-writer` and replace with a minimal GRILL → WRITE → DONE workflow.

## What to build

Rewrite `tools/ai/claude/config/skills/skill-writer/SKILL.md`:

- **Overview**: remove the TDD cycle sentence; keep the canonical tracking path
- **Step 1 (GRILL)**: unchanged
- **Steps 2-5**: remove entirely (RED, GREEN, PRESSURE, OPTIMIZE)
- **New Step 2 (WRITE)**: minimal — read `references/skill-template.md`, create or update the skill file at the canonical location
- **Step 3 (DONE)**: no binary call; simple closing message to commit changes
- **Common Rationalizations**: keep only the symlink warning row; remove the three TDD rows
- **Checklist**: 3 items — user confirmed intent, skill at correct location, skill follows template

Delete three reference files that exclusively served the removed TDD steps:
- `references/pressure-types.md`
- `references/persuasion-principles.md`
- `references/common-rationalization-table.md`

## Acceptance criteria

- [ ] SKILL.md has exactly 3 steps: GRILL, WRITE, DONE
- [ ] Overview contains no mention of TDD
- [ ] WRITE step references `references/skill-template.md`
- [ ] DONE step contains no reference to `skill-writer` binary
- [ ] Common Rationalizations has exactly 1 row (symlink warning)
- [ ] Checklist has exactly 3 items (intent, location, template)
- [ ] `pressure-types.md` deleted
- [ ] `persuasion-principles.md` deleted
- [ ] `common-rationalization-table.md` deleted
