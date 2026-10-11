# API Helpers

An API helper is the set of commands that talk to one web service (Airtable,
Gmail, Notion, Confluence, Make, …) and print the result on stdout. Every
command has the same three layers: a thin ZSH wrapper, a
kebab-case JavaScript bin that parses the arguments with `minimist`, and a
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
  `formatRecord`. The examples stay lintable that way.

## Detail files

- [GLOSSARY.md](GLOSSARY.md) — The terms used across these docs: service, entity, command, its three layers, argument kinds, schemas and verbs.
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

Follow these steps, in order, to add the API helper of a new service:

1. Write the glossary of the service with the `/glossary` skill: its
   authentication kind, its entities (with a fixed or open schema each, see
   [GLOSSARY.md](GLOSSARY.md)), its custom verbs and its terms
   ([reference/docs/glossary.md](reference/docs/glossary.md)).
2. Plan the service before writing any code, with its glossary from step 1 as
   the base.
   - Read the documentation of the API of the service.
   - Ask the user for the credentials early, so that real calls are possible.
   - Confirm the fields of each entity against the real API.
   - Only then write the `# Fields:` header of
     [`list-raw`](reference/commands/list-raw.md).
3. Create the workspace of the service: its `package.json`
   ([architecture.md](architecture.md)), its
   [`getConfig.js`](reference/lib/getConfig.md) and its
   [`callApi.js`](reference/lib/callApi.md). For an OAuth API, also read
   [oauth.md](oauth.md): it changes both and adds the command to log in.
4. For each entity, implement every verb that the API allows. Choose the arguments of each command
   ([reference/commands/README.md](reference/commands/README.md), [arguments.md](arguments.md)).
5. Implement the commands of each entity in this order, copying the template of
   each verb. Create [`format<Entity>.js`](reference/lib/formatEntity.md) for each entity. It
   is a simple identity pass-through by default and evolves only if/when needed.
   - [`search`](reference/commands/search.md), first: `list-raw` sits on top of
     it. Skip it only if the service has no endpoint to search the entities.
   - [`list-raw`](reference/commands/list-raw.md)
   - [`list`](reference/commands/list.md)
   - [`read`](reference/commands/read.md)
   - [`create`](reference/commands/create.md)
   - [`update`](reference/commands/update.md)
   - [`delete`](reference/commands/delete.md)
   - a [custom verb](reference/commands/custom.md), for an action that is not
     CRUD.

   Each command prints the format described in its own file, for example
   [`list-raw`](reference/commands/list-raw.md#role).
   Each command has its header documented ([documentation.md](documentation.md)).
   Each command is tested ([tests.md](tests.md)).
