## Guidance

This plan fixes the debugging loop problem: Claude was running 5-10 complex Bash calls requiring manual approval instead of writing a throw-away script.

**Three deliverables — all config/docs, no tests:**
- `tools/ai/claude/config/hooks/allowlist.json` — glob entry for auto-approval
- `tools/ai/claude/config/skills/debug-script/SKILL.md` — new skill (create the directory too)
- `/home/tim/CLAUDE.md` — global Claude instructions (lives outside the repo, edit directly)

**Skill location:** skills live at `tools/ai/claude/config/skills/<name>/SKILL.md` in the oroshi repo. The `~/.claude/skills/` directory is a symlink — always edit via the worktree path, never via the symlink.

**Allowlist format:** `tools/ai/claude/config/hooks/allowlist.json` is a flat JSON array of strings. Glob patterns (e.g. `/**` suffix) are supported via solkan's glob feature. Add new entries in alphabetical order — except the scripts glob which goes first for visibility.

**Verification for issue 01:**
```zsh
solkan --allow-list-file tools/ai/claude/config/hooks/allowlist.json "/tmp/oroshi/claude/scripts/foo"
```

**Skill frontmatter format** (see existing skills for reference):
```yaml
---
name: debug-script
description: Use when writing throw-away debug or exploration scripts.
---
```

**Issue 03 note:** `/home/tim/CLAUDE.md` lives in the home directory, outside the oroshi repo. Edit it directly. The jq/jo rules currently in `## Throw-away scripts` should be reviewed — check if they are better placed under `## Code`.

## Discoveries
