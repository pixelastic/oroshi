# Testing

- DO NOT import test globals (`describe`, `it`, `expect`, `vi`, `beforeEach`, `afterEach`), they are already loaded
- DO NOT auto-clean mocks between tests, they are already cleaned
- Use variable names: `input` (passed), `actual` (result), `expected` (assertion)
- `describeName` and `testName` are available in each test
- `dedent` is available for multiline strings

## it.each — multiple inputs

- Use `it.each` when testing the same behavior with different inputs
- Use `input` and `expected` keys. If multiple inputs, use one named key per input
- Use a `title` key if input is too long

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

## Error testing

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


## Mocking

- Import `__` to spy/mock private functions
- Use it to mock calls to APIs, filesystems or ENV variables
- DO NOT use `mockResolvedValue` or `mockRejectedValue`. Use `mockReturnValue` instead

```javascript
import { __, fetchData } from '../fetchData.js';

describe('fetchData', () => {
  it('returns parsed result', async () => {
    vi.spyOn(__, 'request').mockReturnValue({ data: 'ok' });
    vi.spyOn(__, 'log').mockReturnValue();

    const actual = await fetchData('url');

    expect(__.request).toHaveBeenCalledWith('url');
    expect(actual).toEqual('ok');
  });
});
```
