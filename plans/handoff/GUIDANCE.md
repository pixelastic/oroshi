## Guidance

This plan renames the `handoff` skill to `sidequest` and consolidates ephemeral Claude files under `/tmp/oroshi/claude/`.

**Repo layout relevant to this plan:**
- Skill definition: `~/.claude/skills/handoff/SKILL.md` → will become `~/.claude/skills/sidequest/SKILL.md`
- Companion script: `scripts/bin/ai/handoff/handoff-end` → will become `scripts/bin/ai/sidequest/sidequest-end`
- Global config: `~/CLAUDE.md` (throw-away scripts path)
- Permissions: `~/.claude/settings.json` (`permissions.allow` array)

**Ephemeral tmp tree (target state):**
```
/tmp/oroshi/claude/
├── hooks/       (existing — unchanged)
├── sessions/    (existing — unchanged)
├── sidequests/  (new — sidequest documents)
└── scripts/     (new — one-off throw-away scripts)
```

**Linting:** `zshlint <filepath>` for zsh scripts. No bats tests for this plan.

**Conventions:**
- Slug format: 3–5 words, kebab-case, derived from conversation content
- `sidequest-end` takes one argument: absolute file path; pipes `@<path>` to `clipboard-write`
- No `sidequest-start` script — whitelisting eliminates the need for it

## Discoveries

<!-- Append findings here after each issue, format: ### Issue XX — short title -->
