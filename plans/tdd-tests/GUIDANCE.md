## Guidance

**Repo context:** All skills live in `/home/tim/.oroshi/tools/ai/claude/config/skills/` — each skill is a directory with a `SKILL.md` and optionally a `references/` subdirectory. The `~/.claude/skills/` entries are symlinks to these.

**Skills are siblings:** `ralph/`, `tdd/`, `to-issues/` are all siblings under the same parent. Cross-skill references use relative paths: `../tdd/references/behavioral-tests.md`.

**Cross-skill link pattern:** Use markdown links with an explicit `Read` instruction:
```
Read [behavioral-tests.md](../tdd/references/behavioral-tests.md) before writing tests.
```
Do NOT use the `@` prefix style (e.g. `@../tdd/test-types.md`) — that was a hacky annotation.

**No tests:** All changes in this plan are to skill/reference markdown files. These are the artifacts themselves — no bats or vitest tests are needed or appropriate.

**Editing skill files:** Use the `Edit` tool only (never `Write` on existing files). The skill files may contain invisible UTF-8 glyphs — `Write` strips them silently.

**What "Behavioral Tests" means:** Tests that describe observable scenarios, not spec bullets. Names are sentences (`"first encounter: ask with reason"`). One test may cover multiple ACs. Edge cases only if they represent distinct user-visible behavior.

**What was renamed:** "Permanent Tests" → "Behavioral Tests". The old name described lifespan; the new name describes purpose.

## Discoveries
