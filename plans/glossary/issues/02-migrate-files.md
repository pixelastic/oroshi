## TLDR

Move all existing glossary/context/decisions files to the new layout and create the root index.

## What to build

Migrate every existing doc file to the new convention: `GLOSSARY.md` as a direct sibling of the module it describes, no `__docs/` subfolder.

**Migrations:**
- `hooks/__docs/GLOSSARY.md` → `hooks/GLOSSARY.md` (content unchanged, verify it matches the canonical format)
- `git/worktree/__docs/GLOSSARY.md` → `git/worktree/GLOSSARY.md`, with the content of `__docs/DECISIONS.md` appended as a `## Decisions` section
- `project/CONTEXT.md` → `project/GLOSSARY.md` (the file already uses the right structure; minor header update only)
- Delete `skill-writer/CONTEXT.md` (content outdated)
- Delete both now-empty `__docs/` folders

**Root index:**
Create `GLOSSARY.md` at the repo root. It is a pure index — no term definitions — listing each sub-glossary with a one-line description and a link.

## Acceptance criteria

- [ ] `hooks/GLOSSARY.md` exists; `hooks/__docs/` is gone
- [ ] `git/worktree/GLOSSARY.md` exists and contains the original glossary content plus a `## Decisions` section with the two decisions from the old `DECISIONS.md`
- [ ] `git/worktree/__docs/` is gone
- [ ] `project/GLOSSARY.md` exists; `project/CONTEXT.md` is gone
- [ ] `skill-writer/CONTEXT.md` is gone
- [ ] Root `GLOSSARY.md` exists and links to all three sub-glossaries
- [ ] `find . -name 'CONTEXT.md' -o -name '__docs' -type d` returns no results
