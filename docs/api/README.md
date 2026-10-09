# API Helpers

An API helper is the set of commands that talk to one web service (Airtable,
Gmail, Notion, Confluence, Make, …) and print the result on stdout. Every
command has the same three layers: a thin ZSH wrapper that forwards `"$@"`, a
kebab-case JavaScript bin that parses the arguments with `minimist`, and a
camelCase JavaScript module that calls the service and returns data. All
commands share one command vocabulary, one argument convention and one output
format, so that humans and agents can guess how any service behaves.

## Detail files

- [GLOSSARY.md](GLOSSARY.md) — The terms used across these docs: service, entity, command, its three layers, focused and composite API, argument kinds, schemas and verbs.
- [architecture.md](architecture.md) — Where the code lives, how a service is configured and authenticated, and how it fails.
- [arguments.md](arguments.md) — How a command receives its arguments: positional or named, flag names, content, limit and accounts.
- [documentation.md](documentation.md) — How commands are documented
- [tests.md](tests.md) — How API helpers are tested: what each layer covers, how `__` and `getConfig` are mocked, fixtures, and the `list` bats test.
- [reference/commands/README.md](reference/commands/README.md) — The table of all commands, and the service-specific verbs.
- [reference/commands/list-raw.md](reference/commands/list-raw.md) — Print the entities of a service as plain lines, one per line, for agents and scripts to parse.
- [reference/commands/list.md](reference/commands/list.md) — Print the entities of a service as a colored table, for humans to read.
- [reference/commands/search.md](reference/commands/search.md) — Find entities across a whole service and print them as rich JSON.
- [reference/commands/read.md](reference/commands/read.md) — Take the id of an entity, and print that entity as JSON.
- [reference/commands/create.md](reference/commands/create.md) — Create an entity, and print it as JSON, like `read` does.
- [reference/commands/update.md](reference/commands/update.md) — Change some fields of an entity, and print it as JSON, like `read` does.
- [reference/commands/delete.md](reference/commands/delete.md) — Remove an entity, and print its id.

## Adding an API

Follow these steps, in order, to add the API helper of a new service:

1. Create the workspace of the service: its `package.json`, `getConfig.js` and
   `callApi.js` ([architecture.md](architecture.md)).
2. Choose the entities of the service, and decide whether it is a focused or a
   composite API ([GLOSSARY.md](GLOSSARY.md)).
3. For each entity, decide whether its schema is fixed or open
   ([GLOSSARY.md](GLOSSARY.md)).
4. Choose the verbs each entity needs, and the arguments of each command
   ([reference/commands/README.md](reference/commands/README.md), [arguments.md](arguments.md)).
5. Implement the commands in this order, copying the template of each verb:
   - [`search`](reference/commands/search.md)
   - [`list-raw`](reference/commands/list-raw.md)
   - [`list`](reference/commands/list.md)
   - [`read`](reference/commands/read.md)
   - [`create`](reference/commands/create.md)
   - [`update`](reference/commands/update.md)
   - [`delete`](reference/commands/delete.md).

   Each command prints the format described in its own file, for example
   [`list-raw`](reference/commands/list-raw.md#role).
   Each command has its header documented ([documentation.md](documentation.md)).
   Each command is tested ([tests.md](tests.md)).
6. Define the entities, service verbs and terms of the service in its glossary
   ([architecture.md](architecture.md#service-glossary)).
