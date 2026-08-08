## Guidance

- Memory files live in `~/.claude/projects/<project-dir>/memory/`
- CLAUDE.md convention items use `- DO:` / `- DO NOT:` format
- Issue 01 is HITL — requires user decision per memory
- Issues 02-03 are AFK — purely mechanical
- Settings file: `~/.claude/settings.json`
- No automated tests — verify with grep/ls/cat

## Discoveries

### Issue 01 — Review other projects
- Found 26 files (not 25) across 11 projects (not 9) — count was off in the PRD
- aberlaas CLAUDE.md already had the exact commands from memory — memory was redundant
- signage.md already covered Algolia logo convention for signage context
- User wants teaser conventions in sub-doc (docs/teaser.md), not inline in CLAUDE.md
- User wants `clipboard-write` (via Bash pipe) added to global ~/CLAUDE.md for text output
- Personal/administrative memories (reims succession, décès) should always be discarded — not code conventions
