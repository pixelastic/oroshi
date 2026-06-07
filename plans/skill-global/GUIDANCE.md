## Guidance

### Skill file locations

- Skills source of truth: `tools/ai/claude/config/skills/<name>/SKILL.md` inside the git root
- Global install: `~/.claude/skills/<name>` — symlinks to the main repo, not the current worktree
- Deploy script: `tools/ai/claude/deploy` — creates the symlinks
- **Always edit the tracked copy inside the git root, never `~/.claude/skills/`**

### Files to modify

- `tools/ai/claude/config/skills/skill-writer/SKILL.md`
- `tools/ai/claude/config/skills/ralph/SKILL.md`

### No tests

These are documentation-only edits. No bats or vitest tests apply.

## Discoveries
