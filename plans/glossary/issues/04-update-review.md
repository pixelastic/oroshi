## TLDR

Update `review/SKILL.md` to reference `GLOSSARY.md` instead of `CONTEXT.md`.

## What to build

In `tools/ai/claude/config/skills/review/SKILL.md`, update the standards-sources list.

Replace:
- `` `CONTEXT.md`, `CONTEXT-MAP.md`, per-context `CONTEXT.md` files ``

With:
- `` `GLOSSARY.md`, root `GLOSSARY.md` index ``

Also remove the `docs/adr/` entry from that list (ADRs are now a `## Decisions` section inside GLOSSARY.md, not a separate folder).

## Acceptance criteria

- [ ] `review/SKILL.md` references `GLOSSARY.md` in the standards-sources list
- [ ] No `CONTEXT.md` or `CONTEXT-MAP.md` references remain in the file
- [ ] `docs/adr/` entry removed from the standards-sources list
