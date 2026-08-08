## TLDR

Review 25 memories across 9 non-oroshi projects; migrate useful ones to each project's CLAUDE.md, discard the rest.

## What to build

Read each memory file in `~/.claude/projects/*/memory/` (excluding oroshi). For each project:
1. Read all memory files
2. Present to user with context
3. If worth keeping → add as `- DO:` item in that project's CLAUDE.md (create if needed)
4. Otherwise → mark for deletion

Projects: emulation (6), dashboard (6), solkan (3), algolia-meetups (3), meetups-teasers-generator (2), aberlaas (1), pixelastic-com-gamemaster-armory (1), reims (1).

## Acceptance criteria

- [ ] All 25 memory files reviewed with user
- [ ] Useful conventions migrated to respective project CLAUDE.md files
- [ ] User confirmed each decision (keep/discard)
