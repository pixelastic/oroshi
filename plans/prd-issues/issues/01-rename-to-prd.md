## TLDR

Rename the `to-prd` skill directory to `prd` and update its SKILL.md name and heading.

## What to build

Use `git mv` to rename `tools/ai/claude/config/skills/to-prd/` to `tools/ai/claude/config/skills/prd/`.

Update `prd/SKILL.md`:
- frontmatter `name: to-prd` → `name: prd`
- top-level heading `# To PRD` → `# PRD`

No other content changes.

## Behavioral Tests

Skip — pure refactor.

## Scaffolding Tests

Skip — pure refactor.

## Acceptance criteria

- [ ] Directory is `skills/prd/` (not `skills/to-prd/`)
- [ ] `prd/SKILL.md` frontmatter has `name: prd`
- [ ] `prd/SKILL.md` first heading is `# PRD`
- [ ] All other content in `prd/SKILL.md` is unchanged
