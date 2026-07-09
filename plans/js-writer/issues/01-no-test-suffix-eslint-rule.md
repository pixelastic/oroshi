## TLDR

Add a custom ESLint rule to aberlaas that flags test files with a `.test.` or `.spec.` suffix inside `__tests__/` directories.

## What to build

In the aberlaas repo, create a custom ESLint rule `no-test-suffix` that reports an error when a file matched by the vitest config (`**/__tests__/**/*.{js,ts}`) has a filename containing `.test.` or `.spec.`. The error points to line 1 / column 0 (the Program node) since there is no AST node to attach to.

The rule lives in its own file inside `modules/lint/configs/eslint/rules/`. It is then imported and registered as an inline plugin inside `modules/lint/configs/eslint/vitest.js`.

Severity: `error`. No auto-fix (renaming a file is a filesystem operation outside ESLint's scope).

Tests live in `modules/lint/lib/__tests__/` and exercise the rule via integration (writing real files and calling `run()`), following the same pattern as the existing `js.js` and `vitest.js` test files in that directory.

## Behavioral Tests

**file has `.test.js` suffix inside `__tests__/`**
- linting `__tests__/pull.test.js` reports a `no-test-suffix` error

**file has plain `.js` name inside `__tests__/`**
- linting `__tests__/pull.js` reports no error

**file has `.spec.js` suffix inside `__tests__/`**
- linting `__tests__/pull.spec.js` reports a `no-test-suffix` error

**file has `.test.js` suffix but is outside `__tests__/`**
- linting `lib/pull.test.js` (not inside `__tests__/`) reports no error from this rule

## Acceptance criteria

- [ ] Rule file exists at `modules/lint/configs/eslint/rules/no-test-suffix.js`
- [ ] Rule is registered and enabled (`error`) in `modules/lint/configs/eslint/vitest.js`
- [ ] All four behavioral test cases pass
- [ ] `yarn run lint:fix` passes on the aberlaas repo itself
- [ ] `yarn run test` passes on the aberlaas repo
