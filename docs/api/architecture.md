# Architecture

This file defines the overall architecture of each API service. They all follow
the same pattern, making creating a new one easy by following the current
documentation.

## ZSH and JavaScript

The public commands (available in `$PATH`) are thin ZSH wrappers. They call a
bin, which itself calls an internal JavaScript module.

That underlying module is where all the logic lives, and is thoroughly tested.
The ZSH wrapper and the bin are just thin proxies without much logic.

## Folder layout

All API helpers live in the `api` autoload folder:
`tools/term/zsh/config/functions/autoload/api/`. It holds one workspace per
service, plus one shared workspace.

```text
api/
├── shared/
│   └── __lib/
│       └── package.json
└── <service>/
    ├── __docs/
    │   └── GLOSSARY.md
    ├── <service>-login          # OAuth services only
    ├── <entity>/
    │   ├── <service>-<entity>-list
    │   └── <service>-<entity>-list-raw
    └── __lib/
        ├── package.json
        ├── getConfig.js
        ├── callApi.js
        ├── bin/
        │   └── <service>-<entity>-list-raw.js
        └── <entity>/
            ├── index.js
            ├── <entity>ListRaw.js
            ├── format<Entity>.js
            └── __tests__/
                └── <entity>ListRaw.js
```

Each `<service>` folder contains:

- an `<entity>` folder per entity, to hold the ZSH wrappers
  - `<entity>-search`
  - `<entity>-list`
  - `<entity>-list-raw`
  - `<entity>-read`
  - etc.
- a `__docs/` folder:
  - a `GLOSSARY.md` to define the vocabulary of the service
- a `__lib/` folder to act as a yarn workspace:
  - `package.json` to have its own dependency list. It usually declares
    `@oroshi/api-shared` as a dependency, for the shared API helpers
  - `getConfig.js` to hold the API keys and other config
  - `callApi.js` to query the API in a unified way
  - a `bin/` folder to hold the bins
  - an `<entity>/` folder per entity:
    - a barrel `index.js`
    - a `__tests__/` folder for module tests
    - `<entity>Search.js` to search through all entities
    - `<entity>ListRaw.js` to list entities (machine-readable)
    - `<entity>Read.js` to read a specific entity
    - `format<Entity>.js` to give every command the same output format
    - etc.

The `list` wrapper has no module. It calls `list-raw` and adds colors and
`table`.

### Focused APIs

Focused APIs (where one entity is largely predominant) follow a simpler
architecture that skips the intermediate `<entity>` folders. Their formatting
function is `format.js`, next to `callApi.js`.

## @oroshi/api-shared

`api/shared/__lib` holds the code shared across all API services (HTTP
transport, error handling, etc). Code moves there when at least two services
need it.

## Service glossary

Each service has a `__docs/GLOSSARY.md` that defines its own vocabulary. It uses
the format of the [API glossary](GLOSSARY.md), and does not repeat it. It
contains:

- **Entities**: one entry per entity, with what it is in the service, its
  schema (fixed or open) and its anchor, if it has one.
- **Service verbs**: one entry per verb outside the closed vocabulary
  (`activate`, `run`), with what it does.
- **Service terms**: the words of the service that a command, a flag or an
  error uses, and that could be confused with another (an id, a base, a
  space).

## JavaScript conventions

- One export per file.
- A file is named exactly like the function it exports.
- `__` is a special named export that holds the internals that tests mock.
- All services have a `getConfig.js` and a `callApi.js`.
- Other files carry the entity in their name (e.g. `record/recordListRaw.js`).
  - Exception: the dominant entity of a focused API has no name (`listRaw.js`).
- Modules take what the bin unpacks (a bare id, or an options object when they
  need several arguments), return data and print nothing.
- Bins are in kebab-case and named like their wrapper
  (`bin/<service>-<entity>-list-raw.js`).
- Bins parse arguments with `minimist`, call the module and print the
  result with `console.log`. They have no `try/catch`.

## `getConfig.js`

Each service owns a `getConfig.js` file that exports `getConfig`.

- `getConfig` is the only way to get the credentials and other configuration of
  the service.
- Other modules call it through `__` (`__.getConfig()`), so tests mock it and
  never touch the environment.
- Env variables are prefixed with the name of the service: `<SERVICE>_TOKEN`,
  `<SERVICE>_BASE_URL`.

## `format<Entity>.js`

Each entity owns a `format<Entity>.js` file in its folder (`formatPage.js`,
`formatRecord.js`) that exports `format<Entity>`. A focused API has `format.js`
instead.

- It takes one entity, as returned by the API, and returns a unified formatted version of it.
- By default, it will be the raw object as returned by the API, so agents can
easily understand what it represent.
- Optionally, we may format or clean it, to make it easier for other commands
  to consume.
- Having one central formatting method ensure all helpers deal with the same
shape of the data.
- Other modules call it through `__` (`__.formatEntity()`), so tests mock it.

## Accounts

If a service requires several accounts, one is defined as the default one. Other
accounts can be selected by using `--account <accountName>`.

```text
$ <service>-<entity>-list-raw
$ <service>-<entity>-list-raw --account perso
```

## OAuth

A service that needs a user grant (OAuth) saves its tokens in a service
subfolder of the state folder: `$OROSHI_FOLDER_STATE/<service>/tokens.json`.

The default account uses `tokens.json`. Another account uses
`tokens-<accountName>.json` in the same folder.

When the grant is missing or expired, the command fails with the typed error
`<SERVICE>_LOGIN_REQUIRED`. Its message points to the login command:
`run <service>-login`.

No command logs in by itself. Only `<service>-login` opens a browser, and the
user runs it by hand.

## Errors

- Every failure is a `firostError` with a code: `<SERVICE>_<CAUSE>`
  (`<SERVICE>_TOKEN_MISSING`, `<SERVICE>_LOGIN_REQUIRED`).
- `callApi` turns every non-2xx status into a typed error. The error carries
  the HTTP status and the message of the API in its message
  (`HTTP 404: Not found`).

## Templates

### `package.json`

`<service>/__lib/package.json`:

```json
{
  "name": "@oroshi/<service>",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "description": "Helpers to read and write <service>",
  "license": "MIT",
  "dependencies": {
    "@oroshi/api-shared": "workspace:*",
    "firost": "5.11.0",
    "golgoth": "3.1.0",
    "minimist": "1.2.8"
  }
}
```

### `getConfig.js`

The only way to get the credentials and other configuration.

`<service>/__lib/getConfig.js`:

```javascript
/**
 * Read the configuration of the service from the environment
 * @returns {object} { token }, the credentials of the service
 */
export function getConfig() {
  return {
    token: process.env.SERVICE_TOKEN,
  };
}
```

### `callApi.js`

The only way to talk to the service. It exposes the HTTP call as `__.fetch`, so
tests mock it.

`<service>/__lib/callApi.js`:

```javascript
import { firostError } from 'firost';
import { getConfig } from './getConfig.js';

export let __;

/**
 * Call the API of the service
 * @param {object} options - Request options
 * @param {string} options.path - Path of the endpoint
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request, sent as JSON
 * @returns {object} The JSON response of the API
 */
export async function callApi(options) {
  const { path, method = 'GET', body } = options;
  const { token } = __.getConfig();

  const response = await __.fetch(`https://api.<service>.com/${path}`, {
    method,
    headers: { Authorization: `Bearer ${token}` },
    body: body && JSON.stringify(body),
  });
  const data = await response.json();

  // Every non-2xx status becomes a typed error
  if (!response.ok) {
    throw firostError(
      '<SERVICE>_REQUEST_FAILED',
      `HTTP ${response.status}: ${data.message}`,
    );
  }
  return data;
}

__ = { fetch, getConfig };
```

### `format<Entity>.js`

The one place that defines what a command prints for an entity.

`<service>/__lib/<entity>/format<Entity>.js`:

```javascript
/**
 * Format one entity of the API, to give every command the same output
 * @param {object} response - The entity, as returned by the API
 * @returns {object} The entity, as close as possible to the API
 */
export function formatEntity(response) {
  // Keep the shape of the API, and only tidy what makes it easier to read
  return response;
}
```
