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

**Skill symlink note:** `skills list` uses `entry.isDirectory()` and skips directory symlinks — a new skill only appears after the worktree is merged and a proper symlink is created pointing to `~/.oroshi/...`. Do not create test symlinks in `~/.claude/skills/`; the user will link them after merge.

**Reference skills don't follow the procedural template:** The skill-writer template (Overview, Core Workflow, Rationalizations, Checklist) applies to procedural skills only. Reference skills (like caveman, code-writer) use flat prose sections — acceptable for debug-script.

**`local` is invalid at script top-level:** In zsh shebang scripts, `local` only works inside a function body. Use bare assignment at top level.

## Discoveries
