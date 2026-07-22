# Testing

## Test file naming

- Test files are stored as `__tests__/basename.js` (example: test for `pull.js` → `__tests__/pull.js`)

## Test structure

- Use variable names: `input` (passed), `actual` (result), `expected` (assertion)
- `describeName` and `testName` are available in each test
- `dedent` is available for multiline strings
- Set up shared mocks in `beforeEach` — mock once, not per test
- Use `vi.spyOn(__, 'method').mockReturnValue(...)` to spy/mock private functions
- Prefer `it.each` when testing same setup with different inputs
- Use `input` and `expected` keys in `it.each`. If multiple inputs, use one named key per input. Use a `title` key if input is too long
- Use standalone `it` for side effects, error cases, or anything that doesn't fit input/output variation
- Override a mock inside a specific `it` if needed

```javascript
import { __, getData } from '../getData.js';

describe('getData', () => {
  beforeEach(() => {
    vi.spyOn(__, 'fetch').mockReturnValue({ id: 1, name: 'a' });
  });

  it.each([
    { input: 'id', expected: 1 },
    { input: 'name', expected: 'a' },
  ])('returns $input field', async ({ input, expected }) => {
    const actual = await getData(input);
    expect(actual).toEqual(expected);
  });

  it('saves the result', async () => {
    await getData('id');
    expect(__.save).toHaveBeenCalled();
  });
});
```

## Filesystem tests

- Declare `let testDirectory` at describe scope
- Assign `testDirectory = tmpDirectory('scope')` in `beforeEach`
- Clean up via `await remove(testDirectory)` in `afterEach`
- Each `it` does its own filesystem work

```javascript
import { remove, tmpDirectory } from 'firost';

describe('myFeature', () => {
  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('myFeature');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('writes to the test directory', async () => {
    // use testDirectory as path root
  });
});
```

## Assertions

- Prefer `toEqual` with the exact expected value when the full content is known
- Reserve `arrayContaining`/`objectContaining` for genuine subset tests
- Use `try`/`catch` with a `let actual` to test errors

```javascript
it('throws on invalid input', async () => {
  let actual = null;
  try {
    await myFn(null);
  } catch (error) {
    actual = error;
  }
  expect(actual).toHaveProperty('code', 'ERR_INVALID');
  expect(actual.message).toContain('must be a string');
});
```
