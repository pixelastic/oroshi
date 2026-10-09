# API Helpers

An API helper is the set of commands that talk to one web service (Airtable,
Gmail, Notion, Confluence, Make, …) and print the result on stdout. Every
command has the same three layers: a thin ZSH wrapper, a
kebab-case JavaScript bin that parses the arguments with `minimist`, and a
camelCase JavaScript module that calls the service and returns data. All
commands share one command vocabulary, one argument convention and one output
format, so that humans and agents can guess how any service behaves.

## Detail files

- [GLOSSARY.md](GLOSSARY.md) — The terms used across these docs: service, entity, command, its three layers, argument kinds, schemas and verbs.
- [architecture.md](architecture.md) — Where the code lives, how a service is configured and authenticated, and how it fails.
- [arguments.md](arguments.md) — How a command receives its arguments: positional or named, flag names, content, limit and accounts.
- [documentation.md](documentation.md) — How commands are documented: the header of the ZSH wrapper, and how agents find it with `helper-list` and `helper-documentation`.
- [tests.md](tests.md) — How API helpers are tested: what each layer covers, how `__` and `getConfig` are mocked, fixtures, and the `list` bats test.
- [reference/commands/README.md](reference/commands/README.md) — The table of all commands, and the custom verbs.
- [reference/commands/list-raw.md](reference/commands/list-raw.md) — Print the entities of a service as plain lines, one per line, for agents and scripts to parse.
- [reference/commands/list.md](reference/commands/list.md) — Print the entities of a service as a colored table, for humans to read.
- [reference/commands/search.md](reference/commands/search.md) — Find entities of one type and print them as rich JSON.
- [reference/commands/read.md](reference/commands/read.md) — Take the id of an entity, and print that entity as JSON.
- [reference/commands/create.md](reference/commands/create.md) — Create an entity, and print it as JSON, like `read` does.
- [reference/commands/update.md](reference/commands/update.md) — Change some fields of an entity, and print it as JSON, like `read` does.
- [reference/commands/delete.md](reference/commands/delete.md) — Remove an entity, and print its id.
- [reference/commands/login.md](reference/commands/login.md) — Get the OAuth tokens of a service, and save them. Only OAuth APIs have it.
- [reference/commands/custom.md](reference/commands/custom.md) — Add a verb of your own, for an action that is not CRUD.
- [reference/lib/getConfig.md](reference/lib/getConfig.md) — The only way to read the credentials and the configuration of a service.
- [reference/lib/callApi.md](reference/lib/callApi.md) — The only way to talk to a service, and the typed error of every failed call.
- [reference/lib/formatEntity.md](reference/lib/formatEntity.md) — The one place that defines what a command prints for an entity.
- [reference/docs/glossary.md](reference/docs/glossary.md) — The role of the glossary of each service, and what it must define.

## Adding an API

Follow these steps, in order, to add the API helper of a new service:

1. Define the service in its glossary: its authentication kind, its entities
   (with a fixed or open schema each, see [GLOSSARY.md](GLOSSARY.md)), its
   custom verbs and its terms
   ([reference/docs/glossary.md](reference/docs/glossary.md)). The next steps
   follow from it.
2. Create the workspace of the service: its `package.json`
   ([architecture.md](architecture.md)), its
   [`getConfig.js`](reference/lib/getConfig.md) and its
   [`callApi.js`](reference/lib/callApi.md).
3. Choose the verbs each entity needs, and the arguments of each command
   ([reference/commands/README.md](reference/commands/README.md), [arguments.md](arguments.md)).
4. Implement the commands of each entity in this order, copying the template of
   each verb. The first command creates the folder of the entity, and its
   [`format<Entity>.js`](reference/lib/formatEntity.md): write it once a real
   API response shows what to tidy.
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
5. For an OAuth API only, implement its [`login`](reference/commands/login.md).
   A key API has none.
