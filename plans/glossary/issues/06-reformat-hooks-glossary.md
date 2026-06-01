## TLDR

Reformat `hooks/GLOSSARY.md` to match the canonical `GLOSSARY-FORMAT.md` template.

## What to build

The file currently uses a decision-layer structure (tables, layer headings) instead of the canonical block format. Reformat it to conform:

- Add a `## Language` section containing all terms (`allow`, `reject`, `rewrite`, `ignore`, `auto-approve`, `ask user`) in block format
- Each term: one-sentence definition + `_Avoid_:` line
- Group the 4-cases table and execution order under a `## Relationships` or `## Decisions` section as appropriate
- Add `## Flagged ambiguities` if any term collisions exist

Content accuracy must be preserved — only the structure changes.

## Acceptance criteria

- [ ] `hooks/GLOSSARY.md` has a `## Language` section
- [ ] Every term uses the block format: `**Term**:\nDef\n_Avoid_: ...`
- [ ] Every term has an `_Avoid_` line (even if empty)
- [ ] The 4-cases table and execution order are retained, under an appropriate section
- [ ] No information from the original file is lost
