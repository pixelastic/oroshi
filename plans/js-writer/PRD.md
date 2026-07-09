## Problem Statement

The `js-writer` skill generates JavaScript code that follows the skill's instructions correctly, but the output still diverges from the author's personal coding standards. Specifically:

1. Test files generated inside `__tests__/` directories are named with a `.test.js` suffix (e.g. `remote.test.js`), which is redundant — the directory already indicates they are tests. The correct name is just `remote.js`.
2. Multiple related exports are placed in a single file (e.g. `pull`, `push`, `run`, `readFile`, `writeFile` all in `remote.js`), instead of one export per file with a barrel `index.js` that re-exports them. This makes it hard to locate individual functions.
3. The skill's TDD workflow collapses "make it work" and "refactor" into a single step, unlike the author's other language skills (python-writer) which keeps them separate.

## Solution

Enforce standards at two levels:

1. **Linter** (aberlaas): Add a custom ESLint rule `no-test-suffix` that detects test files inside `__tests__/` directories whose filename contains `.test.` or `.spec.`. The rule reports an error (no auto-fix) so an agent running lint will see the violation and rename the file.

2. **Skill** (oroshi): Update the `js-writer` SKILL.md and its `testing.md` reference to:
   - Document the one-export-per-file + barrel `index.js` structure
   - Remove the existing multi-export code example that contradicts the rule
   - Split the TDD workflow step into: make it work → refactor → lint (aligning with python-writer)
   - Document the test file naming convention (no `.test.` suffix inside `__tests__/`)

## User Stories

1. As an agent following js-writer, I want a clear structural rule about file layout, so that I don't put multiple exports in a single file.
2. As an agent following js-writer, I want an example showing a barrel `index.js` alongside individual function files, so that I know exactly how to structure grouped functions.
3. As an agent following js-writer, I want to know that test files in `__tests__/` should not have a `.test.` suffix, so that I name them correctly from the start.
4. As an agent following js-writer, I want lint to catch the `.test.` suffix error when it occurs, so that I can fix it before the code is reviewed.
5. As an agent following js-writer, I want the TDD workflow split into discrete steps, so that I complete a working implementation before applying style patterns.
6. As a developer running `yarn lint`, I want the `no-test-suffix` rule to flag misnamed test files, so that I notice and can rename them.
7. As a developer maintaining aberlaas, I want the custom rule isolated in its own file with its own tests, so that it can be updated without touching the rest of the vitest config.
8. As an agent following js-writer, I want to understand when to alias an import vs. use the original name, so that I don't add unnecessary aliases when there is no naming conflict.

## Implementation Decisions

### Custom ESLint rule `no-test-suffix` (aberlaas)

- The rule is defined as a standalone module inside `modules/lint/configs/eslint/rules/`.
- It targets files already matched by the vitest config (`**/__tests__/**/*.{js,ts}`), so the rule only needs to check whether the filename contains `.test.` or `.spec.` — the directory check is handled by the config's `files` glob.
- The rule reports on the `Program` node (line 1, column 0) since there is no specific AST node to attach to.
- Severity: `error` (not `warn`) — this is a naming violation that should block lint.
- No auto-fix — the file must be renamed, which is a filesystem operation beyond ESLint's scope.
- The rule is plugged into `vitest.js` as an inline plugin (no npm package required).

### Barrel file convention (js-writer skill)

- When a module exposes multiple related exports, they live in individual files inside a subdirectory (e.g. `lib/remote/pull.js`).
- The subdirectory contains an `index.js` that re-exports everything from the individual files. This `index.js` has no logic — only re-exports.
- `main.js` is reserved exclusively for the single top-level entry point of the whole package. It must not be used as a barrel inside a subdirectory.
- `index.js` is the barrel file convention for subdirectories.

### TDD step split (js-writer skill)

- Step 3 (currently "Write the code") becomes **Step 3 — Make it work**: write the minimal code to make the test pass.
- New **Step 4 — Refactor**: apply all style and structural patterns (one export per file, barrel, import aliases, etc.).
- Lint becomes **Step 5** (was Step 4).
- This mirrors the python-writer workflow exactly.

### Import alias rule (js-writer skill)

- Do not alias imports unless a naming conflict exists in the same file.
- Conflicts are rare once the one-export-per-file rule is in place, because each file has at most one locally-defined name to clash with.
- This is documented as a pattern in the skill, not enforced by a linter rule.

## Testing Decisions

A good test for the `no-test-suffix` rule tests its external behavior only: given a file with a certain name linted under the vitest config, does ESLint report the expected error or not? Implementation details (how the rule checks the filename) are not tested.

**What is tested:**
- The custom `no-test-suffix` ESLint rule in isolation, using ESLint's `RuleTester` API or via the aberlaas integration test (`run()` / `fix()` on real files).
- Cases: file named `pull.test.js` in `__tests__/` → error; file named `pull.js` in `__tests__/` → no error; file named `pull.spec.js` in `__tests__/` → error; file outside `__tests__/` with `.test.js` name → no error (not matched by the config glob).

**Prior art:**
- `modules/lint/lib/__tests__/js.js` — integration tests that write real files and call `run()` / `fix()`, following the `vi.spyOn(__, ...)` + `try/catch` pattern used throughout the codebase.

**Not tested:**
- SKILL.md and `testing.md` edits — documentation changes are the artifact themselves, no test wrapper needed.

## Out of Scope

- Updating existing files in any project to comply with the new naming/structure rules — those will surface naturally at next lint run.
- Auto-fix for the `no-test-suffix` rule — renaming a file requires filesystem operations outside ESLint's scope.
- Updating zsh-writer to add an explicit "Refactor" step — out of scope for this plan; the user confirmed zsh-writer already follows the pattern conceptually.
- Adding the `no-test-suffix` rule to non-vitest configs (js.js, react.js, etc.) — the rule only makes sense inside `__tests__/`.
