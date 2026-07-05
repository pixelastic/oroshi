## TLDR

Update `SKILL.md` to document the new output formats from `phone-pickup-list` and `phone-pickup-read`.

## What to build

The skill's Step 1 and Step 3 descriptions still reference the old raw JSON outputs. Update them to reflect:

- Step 1: `phone-pickup-list` now returns a minimal JSON array `[{id, date, tags, title}]`
- Step 3: `phone-pickup-read` now returns pure Markdown

No tests — documentation only.

## Acceptance criteria

- [ ] Step 1 in `SKILL.md` describes the minimal JSON array format `{id, date, tags, title}`
- [ ] Step 3 in `SKILL.md` states that output is pure Markdown
- [ ] No references to raw Notion API JSON remain in the skill description
