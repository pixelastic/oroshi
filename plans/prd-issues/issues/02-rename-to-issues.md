## TLDR

Rename the `to-issues` skill directory to `issues` and update its SKILL.md name and heading.

## What to build

Use `git mv` to rename `tools/ai/claude/config/skills/to-issues/` to `tools/ai/claude/config/skills/issues/`.

Update `issues/SKILL.md`:
- frontmatter `name: to-issues` → `name: issues`
- top-level heading `# To Issues` → `# Issues`

No other content changes.

## Behavioral Tests

Skip — pure refactor.

## Scaffolding Tests

Skip — pure refactor.

## Acceptance criteria

- [ ] Directory is `skills/issues/` (not `skills/to-issues/`)
- [ ] `issues/SKILL.md` frontmatter has `name: issues`
- [ ] `issues/SKILL.md` first heading is `# Issues`
- [ ] All other content in `issues/SKILL.md` is unchanged
