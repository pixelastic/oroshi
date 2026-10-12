# API Helpers

An API helper is the set of commands that talk to one web service (Airtable,
Gmail, Notion, Confluence, Make, …) and print the result on stdout. Every
command has the same three layers: a thin ZSH wrapper, a
kebab-case JavaScript bin that parses the arguments with `parseBinArgs`, and a
camelCase JavaScript module that calls the service and returns data. All
commands share one command vocabulary, one argument convention and one output
format, so that humans and agents can guess how any service behaves.

This file holds the generic rules. The exceptions are defined in the files of
the commands concerned.

## Template notation

- A name in angle brackets (`<service>`, `<entity>`, `<Entity>`) in a path, a
  string or a comment is a placeholder. Replace it with the real name
  (`airtable`, `record`, `Record`).
- Inside a JavaScript identifier, the plain words `entity` and `Entity` play
  the same role: `entityRead` becomes `recordRead`, and `formatEntity` becomes
  `formatRecord`.

## Detail files

- [GLOSSARY.md](GLOSSARY.md) — The terms used across these docs: service, entity, command, its three layers, argument kinds, schemas and verbs.
- [adding-an-api.md](adding-an-api.md) — The steps, in order, to add the API helper of a new service, and the final checklist.
- [oauth.md](oauth.md) — What an OAuth API adds to the generic rules, in one place.
- [architecture.md](architecture.md) — Where the code lives, how a service is configured and authenticated, and how it fails.
- [arguments.md](arguments.md) — How a command receives its arguments: positional or named, flag names, content, limit and accounts.
- [documentation.md](documentation.md) — How commands are documented: the header of the ZSH wrapper, and how agents find it with `helper-list` and `helper-documentation`.
- [tests.md](tests.md) — How API helpers are tested: what each layer covers, how `__` and `getConfig` are mocked, test data, and the `list` bats test.
- [reference/commands/README.md](reference/commands/README.md) — The overview of all commands: the table of verbs, and the custom verbs.
- [reference/lib/getConfig.md](reference/lib/getConfig.md) — The only way to read the credentials and the configuration of a service.
- [reference/lib/setAccount.md](reference/lib/setAccount.md) — Choose the account that `getConfig` reads, for the whole command.
- [reference/lib/callApi.md](reference/lib/callApi.md) — The only way to talk to a service, and the error of every failed call.
- [reference/lib/formatEntity.md](reference/lib/formatEntity.md) — The one place that defines what a command prints for an entity.
- [reference/docs/glossary.md](reference/docs/glossary.md) — The role of the glossary of each service, and what it must define.

## Adding an API

To add the API helper of a new service, follow the steps of
[adding-an-api.md](adding-an-api.md).
