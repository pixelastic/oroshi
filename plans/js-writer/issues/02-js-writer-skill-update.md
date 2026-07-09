## TLDR

Update the js-writer skill to enforce one-export-per-file structure, correct test file naming, and a split TDD workflow.

## What to build

In the oroshi repo (worktree `oroshi--js-writer`), update two files under `tools/ai/claude/config/skills/js-writer/`:

### SKILL.md

1. **Step 1 — structure example**: replace the current example (which shows multiple exports in one file) with the correct pattern: one function per file inside a subdomain folder, plus an `index.js` barrel that re-exports them all. `main.js` is the single top-level entry point of the package; `index.js` is the barrel convention for subdirectories.

2. **Step 3 → Make it work** (renamed from "Write the code"): write the minimal code to make the failing test pass. Exit criterion: test is green.

3. **New Step 4 — Refactor**: apply all structural and style patterns (one export per file, barrel `index.js`, import aliasing rules, etc.). Exit criterion: tests still pass after refactor.

4. **Step 5 — Lint** (was Step 4): unchanged except renumbering.

5. **Checklist**: add entries for test file naming and the barrel pattern; remove any checklist item that contradicts the new structure.

### references/testing.md

Add a section on test file naming: files inside `__tests__/` must use the plain module name (e.g. `pull.js`), never a `.test.` or `.spec.` suffix. The directory alone is sufficient to identify them as tests.

## Acceptance criteria

- [ ] Step 1 structure example in SKILL.md shows one-function-per-file + `index.js` barrel, no multi-export file
- [ ] Step 3 is "Make it work" with exit criterion: test passes
- [ ] Step 4 is "Refactor" with exit criterion: tests still pass, patterns applied
- [ ] Step 5 is "Lint" (renumbered)
- [ ] Checklist updated (barrel pattern + test naming entries present)
- [ ] `references/testing.md` documents the no-`.test.`-suffix naming rule
- [ ] No mention of `main.js` as a barrel — that role belongs to `index.js`
