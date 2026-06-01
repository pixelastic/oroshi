## TLDR

Create the standalone `glossary` skill with its canonical format reference.

## What to build

Create two files under `tools/ai/claude/config/skills/glossary/`:

**`SKILL.md`** — describes the skill behaviour:
- Drills vocabulary one question at a time: is this the right term, are there synonyms to avoid, are there contradictions between terms
- Has full conversation context when invoked after `grill-me`; no need to re-ask what was already established
- Infers the target `GLOSSARY.md` location from context; asks only when ambiguous
- Creates the file if absent; updates it if it already exists
- When writing to a sub-module, also updates the root `GLOSSARY.md` index

**`GLOSSARY-FORMAT.md`** — canonical format spec:
- Canonical section order: Language → Relationships → Flagged ambiguities → Example dialogue → Decisions
- All sections optional except Language
- Rules: opinionated term selection, one-sentence definitions, bold term names, `_Avoid_` list per term, cardinality in Relationships, domain-specific terms only
- Decisions criteria: hard to reverse + surprising without context + result of real trade-off
- Single vs multi-repo: single root `GLOSSARY.md` for small repos; root as pure index + sub-glossaries for large repos (when sub-glossaries exist, root contains no term definitions)

## Acceptance criteria

- [ ] `glossary/SKILL.md` exists and describes the terminology-drilling behaviour
- [ ] `glossary/GLOSSARY-FORMAT.md` exists with the 5 canonical sections in order
- [ ] Format rules are documented (opinionated terms, one-sentence defs, Avoid list, domain-only terms)
- [ ] Decisions section criteria are documented
- [ ] Single vs multi-repo placement rules are documented
- [ ] Root index update behaviour is documented in SKILL.md
