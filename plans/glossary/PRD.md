## Problem Statement

The codebase has two overlapping naming conventions for domain documentation (`CONTEXT.md` and `GLOSSARY.md`), two skills that do near-identical things (`grill-me` and `grill-with-docs`), and no clear path from a design conversation to a crystallised vocabulary file. Skills that reference domain documentation (`review`, `to-prd`, `to-issues`) use inconsistent terminology. The `__docs/` subfolder pattern was introduced to house both a glossary and a decisions file, but now that decisions are a section inside the glossary, the subfolder adds indirection without benefit.

## Solution

Standardise on `GLOSSARY.md` as the single artifact for domain vocabulary and architectural decisions. Define a canonical format. Introduce a standalone `glossary` skill that drills terminology and writes the file. Update `grill-me` to offer a clear post-session menu. Delete `grill-with-docs`. Migrate all existing `CONTEXT.md` files and `__docs/` structures to the new layout.

## User Stories

1. As a developer, I want one skill (`grill-me`) to always offer three follow-up paths at the end of a session — write a glossary, write a PRD, or implement directly — so that I never have to remember which skill does what next.
2. As a developer, I want the glossary option to invoke a dedicated `glossary` skill so that vocabulary sharpening is done with the right depth and focus.
3. As a developer, I want to invoke the `glossary` skill independently, without going through `grill-me` first, so that I can update a glossary at any point.
4. As a developer, I want the `glossary` skill to ask targeted terminology questions — is this the right term, are there synonyms to avoid, are there contradictions — so that the resulting file is precise and unambiguous.
5. As a developer, I want the `glossary` skill to infer where to write the file from the conversation context, and only ask when it is ambiguous, so that I don't have to specify the path every time.
6. As a developer, I want the `glossary` skill to update the root `GLOSSARY.md` index automatically when it writes to a sub-module, so that the index stays in sync without manual effort.
7. As a developer, I want a canonical `GLOSSARY.md` format (Language → Relationships → Flagged ambiguities → Example dialogue → Decisions) so that every glossary in the repo looks and reads the same way.
8. As a developer, I want architectural decisions captured as a `## Decisions` section inside the relevant `GLOSSARY.md`, not in a separate file, so that vocabulary and rationale are always co-located.
9. As a developer using a small repo, I want a single root `GLOSSARY.md` that contains all terms, so that I don't need a multi-file structure for simple projects.
10. As a developer using a large repo (like dotfiles), I want a root `GLOSSARY.md` that is a pure index pointing to sub-glossaries, so that the root file stays concise and sub-glossaries remain the source of truth.
11. As a developer, I want `GLOSSARY.md` files to sit directly alongside the code they describe (not inside a `__docs/` subfolder), so that they are easy to discover with a simple glob.
12. As a developer, I want `review`, `to-prd`, and `to-issues` skills to look for `GLOSSARY.md` (not `CONTEXT.md`) when seeking domain context, so that the skills and the files agree on naming.
13. As a developer, I want the `grill-with-docs` skill removed so that there is no confusion between it and the new `grill-me` + `glossary` pair.

## Implementation Decisions

### A — `grill-me` end-of-session flow

Replace the current binary closing question ("implement or write a PRD?") with a three-option menu, always presented in this order:

1. Write a glossary
2. Write a PRD
3. Quick implementation

No explicit instruction to invoke the `glossary` skill — the skill is expected to know what to do.

### B — New `glossary` skill

Two files under `tools/ai/claude/config/skills/glossary/`:

**`SKILL.md`** — skill behaviour:
- Drills terminology one question at a time: is this the right term, are there synonyms to avoid, are there contradictions between terms
- Has full access to the conversation context when invoked after `grill-me`
- Infers the target file location from context; asks the user only when ambiguous
- Creates the file if it does not exist; updates it if it does
- When writing to a sub-module, also updates the root `GLOSSARY.md` index

**`GLOSSARY-FORMAT.md`** — canonical format spec:
- Canonical section order: Language → Relationships → Flagged ambiguities → Example dialogue → Decisions
- All sections optional except Language
- Rules: opinionated term selection, one-sentence definitions, bold term names, avoid-list per term, cardinality in Relationships, only domain-specific terms (no generic programming concepts)
- Decisions criteria: only capture when hard to reverse, surprising without context, and the result of a real trade-off
- Single vs multi-repo: single `GLOSSARY.md` at root for small repos; root as pure index + sub-glossaries for large repos

### C — Delete `grill-with-docs`

Remove the entire `tools/ai/claude/config/skills/grill-with-docs/` folder (SKILL.md, CONTEXT-FORMAT.md, ADR-FORMAT.md).

### D — File migrations

| Before | After | Notes |
|---|---|---|
| `hooks/__docs/GLOSSARY.md` | `hooks/GLOSSARY.md` | content unchanged |
| `git/worktree/__docs/GLOSSARY.md` | `git/worktree/GLOSSARY.md` | merge `__docs/DECISIONS.md` as `## Decisions` section |
| `project/CONTEXT.md` | `project/GLOSSARY.md` | minor format update to match canonical structure |
| `skill-writer/CONTEXT.md` | deleted | content outdated |
| `hooks/__docs/` | deleted | empty after migration |
| `git/worktree/__docs/` | deleted | empty after migration |

### E — Root `GLOSSARY.md`

Create `GLOSSARY.md` at the repo root as a pure index: one-line description per sub-glossary with a link to its file.

### F — `review/SKILL.md`

Replace references to `CONTEXT.md` and `CONTEXT-MAP.md` in the standards-sources list with `GLOSSARY.md`.

### G — Memory cleanup

Delete `feedback_docs_naming.md` from the auto-memory index (the `__docs/` convention it documented no longer applies).

## Testing Decisions

No automated tests. All changes are markdown and configuration files — the files themselves are the artifact. Per project convention, config and skill changes do not get bats or vitest tests written for them.

Manual verification: after migration, `find . -name 'CONTEXT.md' -o -name '__docs'` should return no results.

## Out of Scope

- Renaming the `project/` autoload folder to `context/` (identified as a naming improvement but deferred)
- Updating skills other than `review`, `to-prd`, `to-issues`, and `grill-me` (no other skills reference `CONTEXT.md`)
- Creating glossaries for modules that don't have one yet (out of scope; this PRD only migrates existing files and introduces the new system)
- ADR tooling or structured ADR workflows (the `## Decisions` section in GLOSSARY.md replaces this need)
