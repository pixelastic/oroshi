---
name: js-writer
description: Use when writing or modifying JavaScript code. Apply when adding functions, fixing bugs, or implementing features.
---

# JavaScript Writer

## Overview

Write JavaScript code consistent with my conventions.

Use my preferred libraries — the references explain when and why:

- **[firost](./references/firost.md)** — file I/O, paths, process, HTTP, console, and system utilities
- **[golgoth](./references/golgoth.md)** — common dependencies: `_` (lodash), `pMap`, `dayjs`, `yoctocolors`, `pProps`, and more
- **[aberlaas](./references/aberlaas.md)** — lint, test, and release; start new projects with it

## Core Workflow

### Step 1 — Place the file

**Goal:** Correct path and name.

**Exit criterion:** File exists at correct path with correct name.

- `lib/main.js` as the single top-level entry point for public modules
- One public named function per file (e.g. `lib/myFunction.js`)
- Subdomain folders group related functions; each has an `index.js` barrel re-exporting them
- All tests are located in a `__tests__` folder, sibling of the file it's testing

#### Structure example

```
lib/
  pull/
    __tests__/
      fetch.js
      merge.js
    fetch.js
    index.js      ← barrel: re-exports fetch and merge
    merge.js
  __tests__/
    listEntries.js
  listEntries.js
  main.js         ← single top-level entry point
```

### Step 2 — TDD: Write a failing test

**Goal:** Ensure the bug/feature has a failing test first

**Exit criterion:** Test fails.

Write a failing test for the bug or missing feature you want to implement.

- Use `yarn run test <filepath>` to run the tests
- Use `it.each` when testing similar behavior with different inputs
- Use `try`/`catch` and `let actual` to test errors
- See [Testing](./references/testing.md) for full examples

```javascript
it.each([
  {
    title: "Default path",
    filepath: '/tmp/a',
    options: {},
    expected: 'a'
  },
  {
    title: "Forced path",
    filepath: '/tmp/b',
    options: {
      force: true
    },
    expected: 'b'
  },
])('$title', async ({ filepath, options, expected }) => {
  const actual = await myFn(filepath, options);
  expect(actual).toEqual(expected);
});
```

### Step 3 — Make it work

**Goal:** Write the minimal code to make the failing test pass.

**Exit criterion:** Test is green.

Write the simplest code that makes the test pass.
No patterns yet — just correct behavior.

- Use `yarn run test <filepath>` to run the tests

### Step 4 — Refactor

**Goal:** Apply structural and style patterns without changing behavior.

**Exit criterion:** Tests still pass after refactor.

| Pattern | Rule |
|---|---|
| [Modules](./references/modules.md) | ES6 `import`/`export`; named exports; `.js` extension; `__` for private methods |
| [Style](./references/style.md) | `async/await`; camelCase; minimal `try/catch`; lodash chains for 2+ ops; JSDoc on all fns |
| [firost](./references/firost.md) | File I/O and system operations |
| [golgoth](./references/golgoth.md) | Data transformation, dates, async utilities |
| [aberlaas](./references/aberlaas.md) | Lint, test, release, etc |

```javascript
import { formatEntry } from './formatEntry.js';
import { read, glob } from 'firost';
import { _ } from 'golgoth';

export let __;

/**
 * List all entries in a directory, formatted
 * @param {string} dirPath - Directory to scan
 * @returns {string[]} Formatted entry names
 */
export async function listEntries(dirPath) {
  const files = await __.findFiles(dirPath);

  return _.chain(files)
    .map((f) => formatEntry(f))
    .compact()
    .value();
}

__ = {
  /**
   * @param {string} dir
   * @returns {string[]} Matching file paths
   */
  findFiles(dir) {
    return glob(`${dir}/**/*.js`);
  },
};
```

### Step 5 — Lint

**Goal:** Ensure code follows best practices.

**Exit criterion:** Lint passes.

Write code that passes automated lint.

- Use `yarn run lint:fix` to automatically fix common issues and see remaining ones

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "These comments are clutter, I'll clean them up" | Never remove existing comments |
| "mockResolvedValue is more idiomatic Vitest" | Always `mockReturnValue(value)` — abstract away sync/async |
| "expect().rejects.toThrow() is cleaner" | Use `let actual = null` + try/catch pattern |

## Checklist

- [ ] One public named function per file
- [ ] Subdomain folders have an `index.js` barrel re-exporting all functions
- [ ] `main.js` used only as top-level package entry point, not as a barrel
- [ ] Test files in `__tests__/` use plain module name (e.g. `fetch.js`), no `.test.` or `.spec.` suffix
- [ ] No `for` loop; `_.each`/`_.map`/`pMap` used instead
- [ ] ES6 modules — named exports, `.js` extension on local imports
- [ ] JSDoc on all functions (exported and private in `__`)
- [ ] Existing comments preserved
- [ ] `yarn run lint:fix` run after changes
