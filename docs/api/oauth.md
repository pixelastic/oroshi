# OAuth APIs

An OAuth API authenticates with tokens that the user grants in a browser. This
file holds everything an OAuth API adds to the generic rules.

## What an OAuth API changes

An OAuth API adds a command and a file, and changes two shared modules:

- A [`login`](reference/commands/login.md) command, which gets the tokens and
  saves them.
- A tokens file, written by `login`:
  `$OROSHI_FOLDER_STATE/<service>/tokens.json` (or `tokens-<account>.json` for a
  non-default account). The glossary of the service defines the keys of the
  file.
- A [`getConfig`](#getconfig) that reads the tokens file.
- A [`callApi`](#callapi) that keeps the tokens fresh.

```text
<service>/
├── <service>-login          # wrapper
└── __lib/
    ├── login.js             # module
    ├── bin/
    │   └── <service>-login.js
    └── __tests__/
        └── login.js
```

The wrapper, the bin and the module of `login` follow the template of
[`login`](reference/commands/login.md#template).

## `getConfig`

[`getConfig`](reference/lib/getConfig.md) reads the tokens file instead of an
environment variable: `$OROSHI_FOLDER_STATE/<service>/tokens.json`, the file
that `login` writes. It returns the tokens of the account, with the client
credentials and the settings of the service.

When the tokens file is missing, it fails early with a `firostError` coded
`<SERVICE>_LOGIN_REQUIRED`. The message tells the user what to run:
`run <service>-login`.

The test points `OROSHI_FOLDER_STATE` to a temporary folder. It checks that a
missing tokens file throws the typed error.

## `callApi`

The `callApi` of an OAuth API follows [callApi.md](reference/lib/callApi.md),
with three differences:

- It reads the tokens through `await __.getConfig()`, and authenticates with
  them.
- On a 401 response, it asks the service for new tokens (`__.refreshTokens`),
  rewrites the tokens file, and replays the request once with the new tokens.
  `__.refreshTokens` takes the current tokens and returns the new ones. It keeps
  the fields that the service does not send back.
- It throws `<SERVICE>_LOGIN_REQUIRED` when the refresh fails, or when the
  replayed request answers 401 again. The message says `run <service>-login`. A
  service that signals an expired token another way than a 401 says so in its
  glossary.

## Tests

The test mocks `__.getConfig`, `__.refreshTokens` and `__.fetch`, and checks
these behaviors:

- Given a successful response, the function returns its JSON body, and never
  calls `__.refreshTokens`.
- Given a 401 response, then a success, the function refreshes the tokens,
  rewrites the tokens file and returns the JSON body of the replayed request.
- Given a 401 response, then a failed refresh, the function throws
  `<SERVICE>_LOGIN_REQUIRED`.
- Given a 401 response twice, the function throws `<SERVICE>_LOGIN_REQUIRED`.
- Given another failed response, the function throws the `firostError`, with the
  body of the API as message.
