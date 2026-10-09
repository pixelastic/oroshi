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
- A focused API has no `<entity>/` folder. Its module tests live in
  `__lib/__tests__/`.
- Test names are sentences that say what the code does:
  `returns the entity formatted`, not `test read`.

## Wrappers and bins

Plain wrappers only forward `"$@"`. Bins only parse the arguments with
`minimist`, call the module and print the result. Neither holds logic, so
neither has a test. Their behavior is covered through the module they call.

`list` is the only wrapper with logic: it calls `list-raw` and builds a table.
It is the only command with a bats test. See [`list`](reference/commands/list.md#test).

## vitest

vitest covers the modules, `getConfig` and `callApi`. Tests run with `js-test`.

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

Every other module mocks `callApi` whenever it needs an API response. Their
tests never mock `fetch`.

### Template

`<service>/__lib/<entity>/__tests__/<entity>Read.js`:

```javascript
import { __, entityRead } from '../<entity>Read.js';
import response from './fixtures/<entity>Read.json';

describe('entityRead', () => {
  beforeEach(() => {
    // Mock the collaborators of the module
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatEntity').mockReturnValue({ id: 'formatted' });
  });

  it('calls the API with the id of the entity', async () => {
    await entityRead('recA');

    expect(__.callApi).toHaveBeenCalledWith({ path: 'entities/recA' });
  });

  it('returns the response of the API, formatted', async () => {
    const actual = await entityRead('recA');

    expect(__.formatEntity).toHaveBeenCalledWith(response);
    expect(actual).toEqual({ id: 'formatted' });
  });
});
```

`<service>/__lib/__tests__/callApi.js`:

```javascript
import { __, callApi } from '../callApi.js';

describe('callApi', () => {
  beforeEach(() => {
    // Mock the config, never the environment
    vi.spyOn(__, 'getConfig').mockReturnValue({ token: 'secret-token' });
  });

  it('sends the token of the config', async () => {
    vi.spyOn(__, 'fetch').mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ id: 'recA' }),
    });

    await callApi({ path: 'entities/recA' });

    const headers = __.fetch.mock.calls[0][1].headers;
    expect(headers).toHaveProperty('Authorization', 'Bearer secret-token');
  });

  it('throws a typed error with the status and the message', async () => {
    vi.spyOn(__, 'fetch').mockReturnValue({
      ok: false,
      status: 404,
      json: () => ({ message: 'Not found' }),
    });

    let actual = null;
    try {
      await callApi({ path: 'entities/recZ' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'HTTP 404: Not found');
  });
});
```

## Fixtures

A fixture is a copy of a real API response, cleaned of private data (names,
emails, tokens, ids). It keeps the shape and the quirks of the response, so the
tests exercise what the service really returns.

- Fixtures are JSON files, in a `fixtures/` folder next to the tests that use
  them: `__tests__/fixtures/<entity>Read.json`.
- A fixture is named after the response it holds: `page-with-macros.json`,
  `search-empty.json`.
- A test imports a fixture and returns it from the mocked `callApi`, as in the
  template above. It does not write the response by hand.
- When the service changes its response, a developer refreshes the fixture from
  a new real response, then fixes the tests.

A fixture keeps the response as the service sent it, with only the private
values replaced:

`<service>/__lib/<entity>/__tests__/fixtures/<entity>Read.json`:

```json
{
  "id": "entity-1",
  "title": "Example title",
  "owner": { "id": "user-1", "name": "Jane Doe" },
  "labels": []
}
```

## bats

Only one file require a `bats` test: `list`. `list` reads data from `list-raw`,
filter it, colorize it, and pass it to `table` for a nicer display in columns.

Its test mocks `list-raw` and assert the final output based on various inputs.
Both `list-raw` and `table` are themselves tested, so the tests of `list` only
focus on the transformation aspect.
