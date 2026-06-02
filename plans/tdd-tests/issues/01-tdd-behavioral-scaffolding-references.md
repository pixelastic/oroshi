## TLDR

Split `tdd/references/test-types.md` into `behavioral-tests.md` and `scaffolding-tests.md`, and update `tdd/SKILL.md` to use the new files.

## What to build

Replace the single `test-types.md` reference with two dedicated files — one per test type. Each file is self-contained: it restates the pivot question, defines the test type, and provides the rules specific to that type.

**`behavioral-tests.md`** covers:
- The pivot question (restated as context)
- Definition: verifies observable behavior through the public API; survives any internal rewrite; lives in `__tests__/` forever
- Naming rules: test names are sentences describing a scenario (`"first encounter: ask with reason"`), never AC numbers (`"AC1: ..."`) or issue numbers in comments
- Grouping rules: group by scenario/behavior, not by spec bullet; one test may cover multiple ACs if they describe the same behavior
- Scope rules: edge cases only if they represent distinct user-visible behavior; skip error handling / corrupt state unless it is core behavior

**`scaffolding-tests.md`** covers:
- The pivot question (restated as context)
- Definition: verifies a structural transformation was applied correctly; does not survive a rewrite
- Location: `plans/<slug>/scaffold/<issue-filename>.bats`
- Deletion: removed when the plan is archived

Delete `test-types.md`.

Update `tdd/SKILL.md` Step 1 to reference the two new files (replacing the single `test-types.md` link), and rename "permanent" → "behavioral" in the checklist.

## Behavioral Tests

_Skip — this issue modifies skill/reference markdown files, which are the artifacts themselves._

## Scaffolding Tests

_Skip — no structural transformation of code._

## Acceptance criteria

- [ ] `tdd/references/behavioral-tests.md` exists and contains: pivot question, definition, naming rules, grouping rules, scope rules
- [ ] `tdd/references/scaffolding-tests.md` exists and contains: pivot question, definition, location rule, deletion rule
- [ ] `tdd/references/test-types.md` is deleted
- [ ] `tdd/SKILL.md` Step 1 links to both new files with explicit `Read` instructions
- [ ] `tdd/SKILL.md` checklist uses "behavioral tests" instead of "permanent tests"
