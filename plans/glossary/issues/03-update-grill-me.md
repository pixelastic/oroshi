## TLDR

Replace `grill-me`'s binary closing question with a three-option menu.

## What to build

Update `tools/ai/claude/config/skills/grill-me/SKILL.md`.

Replace the current closing line ("ask if you should implement the solution right away or write a PRD") with a three-option menu, always presented in this order:

1. Write a glossary
2. Write a PRD
3. Quick implementation

No explicit instruction to invoke the `glossary` skill by name — the skill is expected to know what to do.

## Acceptance criteria

- [ ] `grill-me/SKILL.md` closing question offers exactly 3 options in order: glossary → PRD → quick impl
- [ ] No mention of `grill-with-docs` or `CONTEXT.md` remains in the file
