## TLDR

Update `ralph` and `to-issues` to use "Behavioral Tests" instead of "Permanent Tests" and link to the new tdd reference files.

## What to build

Three files to update:

**`ralph/SKILL.md`** Step 2 (RED):
- Replace the current instruction ("Write the tests that cover the acceptance criteria — at least one per criterion") with the behavioral approach: write tests covering the behaviors implied by the ACs, grouped by scenario
- Add explicit `Read` links to `../tdd/references/behavioral-tests.md` and `../tdd/references/scaffolding-tests.md`
- Rename "Permanent Tests" → "Behavioral Tests" in the step body and checklist

**`to-issues/SKILL.md`**:
- Rename all occurrences of "Permanent Tests" → "Behavioral Tests"
- Replace `@../tdd/test-types.md` annotation with a proper markdown link: `[behavioral-tests.md](../tdd/references/behavioral-tests.md)`

**`to-issues/references/issues-XX-slug.md`** (the issue template):
- Rename `## Permanent Tests` → `## Behavioral Tests`
- Update the description under the section to reflect behavioral scope

## Behavioral Tests

_Skip — this issue modifies skill/reference markdown files, which are the artifacts themselves._

## Scaffolding Tests

_Skip — no structural transformation of code._

## Acceptance criteria

- [ ] `ralph/SKILL.md` Step 2 instructs writing tests by behavior/scenario, not 1-per-AC
- [ ] `ralph/SKILL.md` Step 2 links to `../tdd/references/behavioral-tests.md` and `../tdd/references/scaffolding-tests.md`
- [ ] `ralph/SKILL.md` uses "Behavioral Tests" everywhere (step body + checklist)
- [ ] `to-issues/SKILL.md` uses "Behavioral Tests" everywhere
- [ ] `to-issues/SKILL.md` links to `../tdd/references/behavioral-tests.md` (not `@../tdd/test-types.md`)
- [ ] `to-issues/references/issues-XX-slug.md` section is `## Behavioral Tests`
