---
name: js-writer
description: Use when writing or modifying JavaScript code. Apply when adding functions, fixing bugs, or implementing features.
---

# JavaScript Writer

## Overview

Write JavaScript code following established patterns for projects using Aberlaas, Firost, and Golgoth. These libraries provide testing infrastructure, file I/O utilities, and data transformation tools that should be used consistently across all JavaScript projects.

## When to Use

- Writing new JavaScript functions or modules
- Modifying existing JavaScript code
- Creating tests
- Working with file I/O operations
- Performing data transformations

## Dependencies

All JavaScript projects assume these libraries are available:

### Firost - File I/O and System Operations

**File Operations:**
- `read(path)` - Read file content as string
- `write(path, content)` - Write content to file
- `readJson(path)` - Read and parse JSON file
- `writeJson(path, data)` - Write object as JSON
- `readUrl(url)` - Fetch and read URL content
- `readJsonUrl(url)` - Fetch and parse JSON from URL

**File System:**
- `exists(path)` - Check if file/directory exists
- `isFile(path)` - Check if path is a file
- `isDirectory(path)` - Check if path is a directory
- `isSymlink(path)` - Check if path is a symlink
- `copy(source, dest)` - Copy file or directory
- `move(source, dest)` - Move file or directory
- `remove(path)` - Delete file or directory
- `emptyDir(path)` - Remove all contents of directory
- `mkdirp(path)` - Create directory and parents if needed
- `symlink(target, path)` - Create symbolic link

**Path Operations:**
- `absolute(path)` - Convert to absolute path
- `dirname(path)` - Get directory name
- `glob(pattern)` - Find files matching pattern
- `gitRoot()` - Find git repository root
- `packageRoot()` - Find package.json root
- `here()` - Get current file's directory
- `callerDir()` - Get caller's directory
- `commonParentDirectory(paths)` - Find common parent
- `tmpDirectory(name)` - Create temporary directory

**Execution & Process:**
- `run(command)` - Execute shell command
- `which(command)` - Find command in PATH
- `exit(code)` - Exit process with code
- `env(name)` - Get environment variable
- `captureOutput(fn)` - Capture console output

**Utilities:**
- `download(url, dest)` - Download file from URL
- `hash(content)` - Generate hash of content
- `uuid()` - Generate unique identifier
- `sleep(ms)` - Async sleep
- `spinner(max)` - Create progress spinner
- `pulse(message)` - Show progress pulse
- `prompt(message)` - Ask user for input
- `select(message, choices)` - Interactive selection
- `cache(key, fn)` - Cache function results

**URL & Import:**
- `isUrl(string)` - Check if string is URL
- `normalizeUrl(url)` - Normalize URL format
- `urlToFilepath(url)` - Convert URL to filepath
- `firostImport(path)` - Dynamic import helper
- `userlandCaller()` - Get userland caller info

**Console:**
- `consoleInfo(message)` - Log info message
- `consoleSuccess(message)` - Log success message
- `consoleWarn(message)` - Log warning message
- `consoleError(message)` - Log error message

### Golgoth - Utilities

**Data Transformation:**
- `_` - Lodash for data manipulation (map, filter, get, etc.)
  - Use `_.chain()` when performing 2+ operations in sequence
  - Use direct methods for single operations: `_.map(arr, fn)`

**Date Handling:**
- `dayjs` - Date parsing, formatting, and manipulation

**Async Operations:**
- `pMap(items, mapper, options)` - Map array with concurrency control
- `pProps(object)` - Resolve object of promises

## Code Style

### Imports and Exports

**Always use named exports:**

```javascript
// ✅ GOOD - Named export
export function myFunction() {
  // ...
}

export { helperA, helperB };

// ❌ AVOID - Default export
export default function myFunction() {
  // ...
}
```

**Always include `.js` extension in local imports:**

```javascript
// ✅ GOOD
import { read } from './read.js';
import { helper } from '../utils/helper.js';

// ❌ WRONG
import { read } from './read';
```

**Import order:**
1. External packages (npm)
2. Local files

```javascript
import { _ } from 'golgoth';
import { read, write } from 'firost';
import { helper } from './helper.js';
```

### Private Methods Pattern

Export private methods in a `__` object to enable mocking in tests:

```javascript
// Declare at top of file
export let __;

// Use private methods
export function publicApi() {
  __.privateHelper();
}

// Define private methods at bottom
__ = {
  privateHelper() {
    // Implementation
  },
  anotherPrivate() {
    // Implementation
  },
};
```

### Async Code

**Always prefer `async/await` over `.then()`:**

```javascript
// ✅ GOOD
export async function fetchData(url) {
  const content = await read(url);
  const parsed = await parse(content);
  return parsed;
}

// ❌ AVOID
export function fetchData(url) {
  return read(url)
    .then(content => parse(content))
    .then(parsed => parsed);
}
```

Use `.then()` only when the library doesn't support async/await.

### Error Handling

**Only use `try/catch` if you need to do something special before propagating the error:**

```javascript
// ✅ GOOD - Let error propagate
export async function processFile(path) {
  const content = await read(path);
  return transform(content);
}

// ✅ GOOD - Need to cleanup before error propagates
export async function processWithCleanup(path) {
  const tmpFile = await createTemp();
  try {
    const result = await process(tmpFile);
    return result;
  } catch (error) {
    await remove(tmpFile);
    throw error;
  }
}

// ❌ UNNECESSARY - Just re-throwing
export async function processFile(path) {
  try {
    const content = await read(path);
    return transform(content);
  } catch (error) {
    throw error;
  }
}
```

If the goal is for the process to stop on error, don't catch it.

### Naming Conventions

**Use camelCase for all identifiers:**

```javascript
// ✅ GOOD
const myVariable = 'value';
function myFunction() {}
const myObject = { propertyName: 'value' };

// ❌ WRONG
const my_variable = 'value';  // snake_case
const MyVariable = 'value';   // PascalCase (unless it's a class)
```

No classes are used in this codebase, so no PascalCase.

### Data Transformation with Lodash

**Use `_.chain()` when performing 2 or more operations:**

```javascript
// ✅ GOOD - Multiple operations
const result = _.chain(items)
  .map(item => item.value)
  .filter(value => value > 0)
  .value();

// ✅ GOOD - Single operation
const values = _.map(items, item => item.value);

// ❌ UNNECESSARY - Chain for single operation
const values = _.chain(items)
  .map(item => item.value)
  .value();
```

## Testing

### Global Test Functions

**DO NOT import test globals - they are available automatically:**

```javascript
// ✅ GOOD - No imports needed
describe('myFunction', () => {
  it('should work', () => {
    expect(true).toEqual(true);
  });
});

// ❌ WRONG - Don't import
import { describe, it, expect } from 'vitest';

describe('myFunction', () => {
  // ...
});
```

Available globals from Vitest:
- `describe`, `it`, `test`
- `expect`
- `beforeEach`, `afterEach`, `beforeAll`, `afterAll`
- `vi` (mocking utilities - use `vi.spyOn()`, `vi.fn()`, NOT `jest.fn()`)

### Aberlaas Test Helpers

Additional globals provided by Aberlaas setup:
- `describeName` - Name of current describe block
- `testName` - Name of current test
- `dedent` - Template tag for dedenting strings

Mocks are automatically cleaned between tests (no need for manual cleanup).

### Test Pattern with `it.each()`

**When testing the same logic with different inputs/outputs, use `it.each()`:**

```javascript
describe('absolute', () => {
  it.each([
    { input: ['/tmp/one'], expected: '/tmp/one' },
    { input: ['/tmp/one/../two'], expected: '/tmp/two' },
    { input: ['~/config'], expected: `${homePath}/config` },
  ])('$input', async ({ input, expected }) => {
    const actual = absolute(...input);
    expect(actual).toEqual(expected);
  });
});
```

**Pattern:**
- Array of objects with `input` and `expected` keys
- `$input` in test name uses the input value as title
- Variable names: `input` (what's passed), `actual` (result), `expected` (assertion)

### Using `describeName` for Test Isolation

```javascript
describe('myFunction', () => {
  const testDirectory = tmpDirectory(`firost/${describeName}`);

  afterEach(async () => {
    await remove(testDirectory);
  });

  it('should create files', async () => {
    // testDirectory is unique per describe block
  });
});
```

### Mocking Private Methods with `__`

**When you need to mock private methods exported in `__`, use `vi.spyOn()`:**

**Source file (lib/spinner.js):**
```javascript
export let __;

export function spinner() {
  return {
    success(text) {
      __.greenify(text);
    },
  };
}

__ = {
  greenify(text) {
    return colors.green(text);
  },
};
```

**Test file (lib/__tests__/spinner.js):**
```javascript
import { __, spinner } from '../spinner.js';

describe('spinner', () => {
  it('should call greenify when success', () => {
    vi.spyOn(__, 'greenify').mockReturnValue();

    const actual = spinner();
    actual.success('yay');

    expect(__.greenify).toHaveBeenCalledWith('yay');
  });
});
```

**Key points:**
- Import `__` from the module alongside the public function
- Use `vi.spyOn(__, 'methodName')` to mock private methods
- Call the public method - it will use the mocked private method
- Assert with `expect(__.methodName).toHaveBeenCalledWith(...)`

## File Organization

### Directory Structure

```
lib/
├── main.js              # Exports all public functions
├── myFunction.js        # One function per file
├── anotherFunction.js
└── __tests__/           # Tests next to the code
    ├── myFunction.js
    └── anotherFunction.js
```

**Conventions:**
- Tests in `__tests__/` directory next to the code they test
- One function per file
- `lib/main.js` exports all public functions from individual files

**Example `lib/main.js`:**

```javascript
export { read } from './read.js';
export { write } from './write.js';
export { exists } from './exists.js';
// ... export all public functions
```

## Linting

**Run `yarn run lint:fix` after completing a set of related modifications:**

```bash
yarn run lint:fix
```

- Don't lint after every single file change
- Lint once after completing a coherent group of changes
- The linter auto-fixes style issues (semicolons, formatting, etc.)

## JSDoc Documentation

**JSDoc is optional but recommended for exported functions:**

```javascript
/**
 * Read any file on disk
 * @param {string} filepath - Path to the file to read
 * @returns {string} Content of the file
 */
export async function read(filepath) {
  // ...
}
```

Private methods (in `__`) don't need JSDoc.

## Quick Reference

```javascript
// File I/O
import { read, write, readJson, writeJson } from 'firost';
import { exists, remove, copy, mkdirp } from 'firost';

// Data transformation
import { _ } from 'golgoth';
const result = _.chain(data).map().filter().value();

// Async utilities
import { pMap, pProps } from 'golgoth';

// Dates
import { dayjs } from 'golgoth';

// Tests - NO IMPORTS NEEDED
describe('feature', () => {
  it('works', () => {
    expect(actual).toEqual(expected);
  });
});

// Exports
export function myFunction() {}  // Named export
export let __;                    // Private methods
__ = { privateHelper() {} };

// Imports
import { helper } from './helper.js';  // Include .js
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Importing test globals | Don't import `describe`, `it`, `expect` - they're global |
| Using `jest.fn()` | Use `vi.fn()` and `vi.spyOn()` from Vitest, not Jest |
| Using `.then()` chains | Use `async/await` instead |
| Default exports | Use named exports |
| Missing `.js` in imports | Always include: `'./file.js'` |
| Chain for single operation | Use `_.chain()` only for 2+ operations |
| Unnecessary try/catch | Only catch if you need to act before propagating |
| snake_case naming | Use camelCase for everything |
| Linting every file | Lint once after completing a set of changes |
| Manual mock cleanup | Mocks auto-clean between tests |
