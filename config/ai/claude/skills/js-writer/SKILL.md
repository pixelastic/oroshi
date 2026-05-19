---
name: js-writer
description: Use when writing or modifying JavaScript code. Apply when adding functions, fixing bugs, or implementing features.
---

# JavaScript Writer

## Overview

Write JavaScript code consistent with my conventions. Projects use [firost](./references/firost.md) for file I/O, [golgoth](./references/golgoth.md) for data utilities, and [aberlaas](./references/aberlaas.md) for linting/testing/releasing.

## Core Workflow

### Step 1 — Place the file

**Goal:** Correct path and name.

**Exit criterion:** File exists at correct path with correct name.

- `lib/main.js` as main entrypoint
- Names methods at `lib/myFunction.js`, exported by `main.js`
- If needed, a  `helpers` folder can be used to group related internal methods
- All tests are located in a `__tests__` folder, sibling of the file it's testing.

#### Structure example

```
lib/
  __tests__/
    myFunction.js
    myOtherFunction.js
  helpers/
    __tests__/
      filesystem.js
      git.js
    filesystem.js
    git.js
  main.js
  myFunction.js
  myOtherFunction.js
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

### Step 3 — Write the code

**Goal:** Code follows all patterns.

**Exit criterion:** Checklist passes.

Write code that follows the following patterns:


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

### Step 4 — Lint

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

- [ ] One public named function per file; re-exported from `lib/main.js`
- [ ] No `for` loop; `_.each`/`_.map`/`pMap` used instead
- [ ] ES6 modules — named exports, `.js` extension on local imports
- [ ] JSDoc on all functions (exported and private in `__`)
- [ ] Existing comments preserved
- [ ] `yarn run lint:fix` run after changes
