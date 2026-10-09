# Architecture

This file defines the overall architecture of each API service. They all follow
the same pattern, making creating a new one easy by following the current
documentation.

## ZSH and JavaScript

The public commands (available in `$PATH`) are thin ZSH wrappers. They call a
bin, which itself calls an internal JavaScript module.

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

## Service glossary

Each service has a `__docs/GLOSSARY.md` that defines its own vocabulary. It uses
the format of the [API glossary](GLOSSARY.md), and does not repeat it. It
contains:

- **Entities**: one entry per entity, with what it is in the service, its
  schema (fixed or open) and its anchor, if it has one.
- **Custom verbs**: one entry per [custom verb](reference/commands/custom.md)
  (`activate`, `run`), with what it does.
- **Service terms**: the words of the service that a command, a flag or an
  error uses, and that could be confused with another (an id, a base, a
  space).

## JavaScript conventions

- One export per file.
- A file is named exactly like the function it exports.
- `__` is a special named export that holds the internals that tests mock.
- All services have a [`getConfig.js`](reference/lib/getConfig.md) and a
  [`callApi.js`](reference/lib/callApi.md). Each entity has a
  [`format<Entity>.js`](reference/lib/formatEntity.md).
- Other files carry the entity in their name (e.g. `record/recordListRaw.js`).
- Modules take what the bin unpacks (a bare id, or an options object when they
  need several arguments), return data and print nothing.
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

An OAuth API saves the tokens of each account with its
[`login`](reference/commands/login.md) command.

## Errors

- Every failure is a `firostError` with a code: `<SERVICE>_<CAUSE>`
  (`<SERVICE>_TOKEN_MISSING`, `<SERVICE>_LOGIN_REQUIRED`).
- [`callApi`](reference/lib/callApi.md) turns every non-2xx status into a typed
  error. The error carries the HTTP status and the message of the API in its
  message (`HTTP 404: Not found`).

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
    "firost": "5.11.0",
    "golgoth": "3.1.0",
    "minimist": "1.2.8"
  }
}
```
