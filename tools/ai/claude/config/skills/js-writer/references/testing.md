# Testing

## Test file naming

- Test files are stored as `__tests__/basename.js` (example: test for `pull.js` → `__tests__/pull.js`)

## Test conventions

- Use variable names: `input` (passed), `actual` (result), `expected` (assertion)
- `describeName` and `testName` are available in each test
- `dedent` is available for multiline strings
- Use `vi.spyOn(__, 'method').mockReturnValue(...)` to spy/mock private functions

```javascript
import { __, getOrders } from '../getOrders.js';

describe('getOrders', () => {
  beforeEach(() => {
    vi.spyOn(__, 'fetchOrders').mockReturnValue([
      { id: 1, status: 'pending', customer: 'Alice' },
    ]);
  });

  it('returns matching orders', async () => {
    const actual = await getOrders('pending');
    const expected = [{ id: 1, status: 'pending', customer: 'Alice' }];
    expect(actual).toEqual(expected);
  });
});
```

## Setup design

Prefer building a single rich context shared across tests that covers many
edge cases rather than designing a specific context per test.
Each test observes a different facet of that same context.

```javascript
import { __, getOrders } from '../getOrders.js';

describe('getOrders', () => {
  beforeEach(() => {
    vi.spyOn(__, 'fetchOrders').mockReturnValue([
      { id: 1, status: 'pending', customer: 'Alice' },
      { id: 2, status: 'shipped', customer: 'Bob' },
      { id: 3, status: 'shipped', customer: 'Alice' },
    ]);
  });

  it('filters by status', async () => {
    const actual = await getOrders('shipped');
    expect(actual).toEqual([
      { id: 2, status: 'shipped', customer: 'Bob' },
      { id: 3, status: 'shipped', customer: 'Alice' },
    ]);
  });

  it('returns empty when no match', async () => {
    const actual = await getOrders('cancelled');
    expect(actual).toEqual([]);
  });
});
```

## Lifecycle hooks

- `beforeEach` by default — fresh context per test
- `beforeAll` when setup is expensive and all tests are read-only
- Always clean up in the symmetric hook (`afterEach`/`afterAll`)

## `it.each` vs standalone `it`

- Prefer one `it.each` with many rows over many standalone `it` blocks
- Use `input` and `expected` keys in `it.each`. If multiple inputs, use one named key per input. Use a `title` key if input is too long
- Reserve standalone `it` for tests whose **body code differs** — e.g., one uses `toEqual`, another uses `toHaveBeenCalled`, another uses try/catch. If only the inputs and expected values change but the test code is the same, use `it.each`

```javascript
import { __, getOrders } from '../getOrders.js';

describe('getOrders', () => {
  beforeEach(() => {
    vi.spyOn(__, 'fetchOrders').mockReturnValue([
      { id: 1, status: 'pending', customer: 'Alice' },
      { id: 2, status: 'shipped', customer: 'Bob' },
      { id: 3, status: 'shipped', customer: 'Alice' },
    ]);
  });

  it.each([
    { input: 'shipped', expected: 2 },
    { input: 'pending', expected: 1 },
    { input: 'cancelled', expected: 0 },
  ])('returns $expected orders for $input', async ({ input, expected }) => {
    const actual = await getOrders(input);
    expect(actual).toHaveLength(expected);
  });

  it('saves history when fetching', async () => {
    await getOrders('shipped');
    expect(__.saveHistory).toHaveBeenCalled();
  });
});
```

## Filesystem tests

- Isolate each test fixture in their own directory
- Declare `let testDirectory` at describe scope
- Assign `testDirectory = tmpDirectory('scope')` in `beforeEach`

```javascript
import { remove, tmpDirectory } from 'firost';
import { getOrders } from '../getOrders.js';

describe('getOrders', () => {
  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('getOrders');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('writes orders to disk', async () => {
    await getOrders('pending', { outputDir: testDirectory });
    // assert files in testDirectory
  });
});
```

## Assertions

- Prefer `toEqual` with the exact expected value when the full content is known
- Use `toContain` only when the full value is unknown
- Reserve `arrayContaining`/`objectContaining` for genuine subset tests
- Use `try`/`catch` with a `let actual` to test errors

```javascript
it('throws on invalid status', async () => {
  let actual = null;
  try {
    await getOrders(null);
  } catch (error) {
    actual = error;
  }
  expect(actual).toHaveProperty('code', 'ERR_INVALID');
  expect(actual).toHaveProperty('message', 'status must be a string');
});
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "`arrayContaining` + `toHaveLength` is safer because order doesn't matter" | If full content is known, use `toEqual` with the exact array. Sort if order is non-deterministic. `arrayContaining` is for genuine subset checks only. |
| "`toContain` is more resilient to future changes" | If the full value is known in the test context, assert it exactly. Partial checks hide regressions. `toContain` is for genuine substring/subset checks where the full value is unknown or irrelevant. |
| "The shared mock should be minimal so tests are self-contained" | If most tests override the setup, the setup is wrong. |
