# Architecture

This file defines the overall architecture of each API service. They all follow
the same pattern, making creating a new one easy by following the current
documentation.

## ZSH and JavaScript

The public commands are thin ZSH wrappers. Each wrapper is an autoloaded
function, found in `$fpath`. It calls a bin, which itself calls an internal
JavaScript module. Each `__lib` folder is a workspace.

That underlying module is where all the logic lives, and is thoroughly tested.
The ZSH wrapper and the bin are just thin proxies without much logic.

The wrapper does not parse anything. It forwards `"$@"` to the bin. The bin
parses the arguments, as described in [arguments.md](arguments.md#parsing).

## Folder layout

All API helpers live in the `api` autoload folder:
`tools/term/zsh/config/functions/autoload/api/`. It holds one workspace per
service.

```text
api/
├── __shared/
│   └── __lib/
│       ├── package.json
│       └── rawColumn.js
└── <service>/
    ├── __docs/
    │   └── GLOSSARY.md
    ├── <entity>/
    │   ├── <service>-<entity>-list
    │   └── <service>-<entity>-list-raw
    └── __lib/
        ├── package.json
        ├── getConfig.js
        ├── setAccount.js
        ├── callApi.js
        ├── bin/
        │   └── <service>-<entity>-list-raw.js
        └── <entity>/
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
  - `package.json` to have its own dependency list
  - [`getConfig.js`](reference/lib/getConfig.md) to hold the API keys and other
    config
  - [`setAccount.js`](reference/lib/setAccount.md) to choose the account
  - [`callApi.js`](reference/lib/callApi.md) to query the API in a unified way
  - a `bin/` folder to hold the bins
  - an `<entity>/` folder per entity:
    - a `__tests__/` folder for module tests
    - `<entity>Search.js` to search through the entities of that type
    - `<entity>ListRaw.js` to list entities (machine-readable)
    - `<entity>Read.js` to read a specific entity
    - [`format<Entity>.js`](reference/lib/formatEntity.md) to give every command
      the same output format
    - etc.

The `list` wrapper has no module. It calls `list-raw` and adds colors and
`table`.

A service with a single entity keeps its `<entity>` folder. The layout does not
change.

## Shared package

`api/__shared/__lib/` is a yarn workspace (`@oroshi/api-shared`) for the code
every service needs. Services import from it, for example
`import { rawColumn } from '@oroshi/api-shared/rawColumn.js'`.

- `rawColumn.js` formats one value as a column of [`list-raw`](reference/commands/list-raw.md#role).

Move any other code that several services share there.

## Service glossary

Each service has a glossary that defines its own vocabulary. See
[reference/docs/glossary.md](reference/docs/glossary.md) for details.

## JavaScript conventions

- One export per file, plus `__`.
- A file is named exactly like the function it exports.
- `__` is always allowed as an extra export. It holds the internals that tests
  mock.
- All services have a [`getConfig.js`](reference/lib/getConfig.md), a
  [`setAccount.js`](reference/lib/setAccount.md) and a [`callApi.js`](reference/lib/callApi.md). Each entity has a
  [`format<Entity>.js`](reference/lib/formatEntity.md).
- Other files carry the entity in their name (e.g. `record/recordListRaw.js`).
- Modules take one options object, return data and print nothing. The bin
  unpacks the positional argument and the named flags into that object. Its keys
  are the `<entity>Id`, the anchors and the filters.
- Bins are in kebab-case and named like their wrapper
  (`bin/<service>-<entity>-list-raw.js`).
- Bins parse arguments with `minimist`, call the module and print the
  result with `console.log`. They have no `try/catch`.

## Accounts

If a service requires several accounts, one is defined as the default one. Other
accounts can be selected by using `--account <accountName>`.

```text
$ <service>-<entity>-list-raw
$ <service>-<entity>-list-raw --account perso
```

- A **Key API** would read from `<SERVICE>_TOKEN_PERSO` instead of `<SERVICE>_TOKEN`.
- An **OAuth API** would read from `tokens-perso.json` instead of `tokens.json`.

The account never travels through the modules. Every service has a
[`setAccount`](reference/lib/setAccount.md). Every bin that calls the API
extracts `--account` from the parsed arguments, calls `setAccount` with it
before anything else, and keeps it out of the options object.
[`getConfig`](reference/lib/getConfig.md) then returns the credentials of that
account for the whole command.

## Errors

- Every known failure is a `firostError` with a code: `<SERVICE>_<CAUSE>`
- The message of the error holds details (ideally taken from the API response)
- Bins have no `try/catch`. The error reaches the user as it is.

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
