# Architecture

This file defines the overall architecture of each API service. They all follow
the same pattern, making creating a new one easy by following the current
documentation.

## ZSH and JavaScript

The public scripts (available in `$PATH`) are thin ZSH wrappers. They call a
JavaScript binary, which itself calls an internal JavaScript module.

That underlying module is where all the logic lives, and is thoroughly tested.
The ZSH wrapper and the JavaScript binary are just thin proxies without much
logic.

## Folder layout

All API helpers live in the `api` domain folder:
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
  - a `bin/` folder to hold the JavaScript binaries
  - an `<entity>/` folder per entity:
    - a barrel `index.js`
    - a `__tests__/` folder for module tests
    - `<entity>Search.js` to search through all entities
    - `<entity>ListRaw.js` to list entities (machine-readable)
    - `<entity>Read.js` to read a specific entity
    - etc.

The `list` wrapper has no module. It calls `list-raw` and adds colors and
`table`.

### Focused APIs

Focused APIs (where one entity is largely predominant) follow a simpler
architecture that skips the intermediate `<entity>` folders.

## @oroshi/api-shared

`api/shared/__lib` holds the code shared across all API services (HTTP
transport, error handling, etc). Code moves there when at least two services
need it.

## JavaScript conventions

- One export per file.
- A file is named exactly like the function it exports.
- `__` is a special named export that holds the internals that tests mock.
- All services have a `getConfig.js` and a `callApi.js`.
- Other files carry the entity in their name (e.g. `record/recordListRaw.js`).
  - Exception: the dominant entity of a focused API has no name (`listRaw.js`).
- Modules take an options object, return data and print nothing.
- Binaries are in kebab-case and named like their wrapper
  (`bin/service-entity-list-raw.js`).
- Binaries parse arguments with `minimist`, call the module and print the
  result with `console.log`. They have no `try/catch`.

## `getConfig.js`

Each service owns a `getConfig.js` file that exports `getConfig`.

- `getConfig` is the only way to get the credentials and other configuration of
  the service.
- Other modules call it through `__` (`__.getConfig()`), so tests mock it and
  never touch the environment.
- Env variables are prefixed with the name of the service: `SERVICE_TOKEN`,
  `SERVICE_BASE_URL`.

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
