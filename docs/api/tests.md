# Tests

This file defines how API helpers are tested. Tests cover the logic, and the
logic lives in the JavaScript modules. Tests never reach the network.

## No real network

No test calls a real service, ever. Every test mocks the call at the closest
point to the code under test:

- A command module test mocks `callApi`.
- A `callApi` test mocks the HTTP call.
- A `list` test mocks `list-raw`.

## What is tested where

| Layer             | Tested | Tool   | Location                             |
|-------------------|--------|--------|--------------------------------------|
| Module            | Yes    | vitest | `__lib/<entity>/__tests__/`          |
| `getConfig.js`    | Yes    | vitest | `__lib/__tests__/getConfig.js`       |
| `callApi.js`      | Yes    | vitest | `__lib/__tests__/callApi.js`         |
| `list` wrapper    | Yes    | bats   | `<entity>/__tests__/`                |
| Other wrappers    | No     |        |                                      |
| Bin               | No     |        |                                      |

- A test file has the name of the file it tests (`recordRead.js` is tested by
  `__tests__/recordRead.js`), with no `.test.` or `.spec.` suffix.
- Test names are sentences that say what the code does:
  `returns the entity formatted`, not `test read`.

## Wrappers and bins

Plain wrappers only pass their arguments on. Bins only parse the arguments with
`minimist`, call the module and print the result. Neither holds logic, so
neither has a test. Their behavior is covered through the module they call.

`list` is the only wrapper with logic: it calls `list-raw` and builds a table.
It is the only command with a bats test. See [`list`](reference/commands/list.md#test).

## vitest

vitest covers the modules, `getConfig` and `callApi`. Tests run with `js-test`.
A test mocks a collaborator through `__`, with `vi.spyOn(__, 'name')`. The
`js-writer` skill defines this convention
([architecture.md](architecture.md#javascript-conventions)).

### Mocking `getConfig`

Modules call `getConfig` through `__`, to get credentials and other config
variables. Tests mock it to replace it with a config object:

```javascript
vi.spyOn(__, 'getConfig').mockReturnValue({ token: 'secret-token' });
```

### Mocking HTTP

`callApi` is the only module that talks to the network, and it has its own
tests. They mock the HTTP call (`__.fetch`) to return a response with a status
and a body, and assert on the request it received (url, method, headers, body).
The behaviors to cover are listed in [`callApi`](reference/lib/callApi.md#template).

Every other module mocks `callApi` whenever it needs an API response. Their
tests never mock `fetch`.

### Template

`<service>/__lib/<entity>/__tests__/<entity>Read.js`:

```javascript
import { __, entityRead } from '../<entity>Read.js';

describe('entityRead', () => {
  // A minimal inline response: only the fields the test needs
  const response = { id: 'recA' };

  beforeEach(() => {
    // Mock the collaborators of the module
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatEntity').mockReturnValue({ id: 'formatted' });
  });

  it('calls the API with the id of the entity', async () => {
    await entityRead({ entityId: 'recA' });

    expect(__.callApi).toHaveBeenCalledWith('entities/recA');
  });

  it('returns the response of the API, formatted', async () => {
    const actual = await entityRead({ entityId: 'recA' });

    expect(__.formatEntity).toHaveBeenCalledWith(response);
    expect(actual).toEqual({ id: 'formatted' });
  });
});
```

## Test data

Module tests mock `callApi` and return a minimal inline object, as in the
template above. A command whose test needs more says so in its own file.

## bats

Only one file requires a `bats` test: `list`. `list` reads data from `list-raw`,
colors the id, and passes it to `table` for a nicer display in columns. A
failing `list-raw` makes `list` fail.

Its test mocks `list-raw` and asserts the final output based on various inputs.
Both `list-raw` and `table` are themselves tested, so the tests of `list` only
focus on the transformation aspect.
