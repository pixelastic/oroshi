## Guidance

**Skills live at:** `tools/ai/claude/config/skills/<skill-name>/`

**Existing glossary files to reference for style:**
- `tools/term/zsh/config/functions/autoload/git/worktree/__docs/GLOSSARY.md` — best example of canonical format
- `tools/ai/claude/config/hooks/__docs/GLOSSARY.md` — second example

**Existing skill structure to follow:** Look at any existing skill (e.g. `grill-me/`, `to-prd/`) for how SKILL.md and reference files are organised.

**No automated tests.** All changes are markdown/config files — the files are the artifact. No bats or vitest tests needed.

**Verification command:** After issue 02, run:
```
find . -name 'CONTEXT.md' -o \( -name '__docs' -type d \)
```
Should return no results.

**Memory file location:** `~/.claude/projects/-home-tim--oroshi/memory/`

## Discoveries

### Issue 02 — Migrate files

- `hooks/GLOSSARY.md` does not match the canonical `GLOSSARY-FORMAT.md` template (no `## Language`, terms in tables, no `_Avoid_` lists). The issue spec said "content unchanged" so it was migrated as-is. A future issue should reformat it to the canonical structure.
- Root `GLOSSARY.md` must use `## Modules` heading + bullet list (`- [Name](path) — desc`), not a markdown table — per `GLOSSARY-INDEX-FORMAT.md`.
