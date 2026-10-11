# OAuth APIs

An OAuth API authenticates with tokens that the user grants in a browser. This
file holds everything an OAuth API adds to the generic rules.

## What an OAuth API changes

An OAuth API adds a command and a file, and changes two shared modules:

- A [`login`](reference/commands/login.md) command, which gets the tokens and
  saves them.
- A tokens file, written by `login`:
  `$OROSHI_FOLDER_STATE/<service>/tokens.json` (or `tokens-<account>.json` for a
  non-default acount).
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
that `login` writes.

When the tokens file is
missing, it fails early with a `firostError`
coded `<SERVICE>_LOGIN_REQUIRED`. The message tells the user what to run:
`run <service>-login`.

The test points `OROSHI_FOLDER_STATE` to a temporary folder. It checks that a
missing tokens file throws the typed error.

## `callApi`

The `callApi` of an OAuth API follows
[callApi.md](reference/lib/callApi.md), with three differences:

- It reads the tokens through `await __.getConfig()`, and authenticates with them.
- It tries to keep the tokens fresh, on a best-effort basis. When they are about
  to expire, it asks the service for new ones (`__.refreshTokens`), and rewrites
  the tokens file. A failed refresh does not stop the call: it goes on with the
  current tokens.
- It throws `<SERVICE>_LOGIN_REQUIRED` when the API reports a missing or invalid
  login, usually with a 401. The message says `run <service>-login`.

## Tests

The test mocks `__.getConfig`, `__.refreshTokens` and `__.fetch`, and checks
these behaviors:
- Given a successful response, the function returns its JSON body, and the
  request holds the tokens returned by `__.refreshTokens`.
- Given a failed refresh, the function still calls the API with the current
  tokens.
- Given a 401 response, the function throws `<SERVICE>_LOGIN_REQUIRED`.
- Given another failed response, the function throws the `firostError`, with the
  body of the API as message.
