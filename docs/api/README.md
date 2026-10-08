# API Helpers

An API helper is the set of commands that talk to one web service (Airtable,
Gmail, Notion, Confluence, Make, …) and print the result on stdout. Every
command has the same three layers: a thin ZSH wrapper that forwards `"$@"`, a
kebab-case JavaScript bin that parses the arguments with `minimist`, and a
camelCase JavaScript module that calls the service and returns data. All
commands share one command vocabulary, one argument convention and one output format, so that
humans and agents can guess how any service behaves.

## Detail files

- [GLOSSARY.md](GLOSSARY.md) — The terms used across these docs: service, entity, command, focused and composite API, argument kinds, schemas and verbs.
- [architecture.md](architecture.md) — Where the code lives, how a service is configured and authenticated, and how it fails.
- [documentation.md](documentation.md) — How commands are documented
- [arguments.md](arguments.md) — How a command receives its arguments: positional or named, flag names, content, limit and accounts.
- [output.md](output.md) — What a command prints: the raw format, JSON, streams, and the `# Usage:` and `# Fields:` headers.
- [commands/README.md](commands/README.md) — The table of all commands, and the service-specific verbs.
- [commands/list-raw.md](commands/list-raw.md) — Print the entities of a service as plain lines, one per line, for agents and scripts to parse.
- [commands/list.md](commands/list.md) — Print the entities of a service as a colored table, for humans to read.
- [commands/search.md](commands/search.md) — Find entities across a whole service and print them as rich JSON.
- [commands/read.md](commands/read.md) — Take the id of an entity, and print that entity as JSON.
- [commands/create.md](commands/create.md) — Create an entity, and print it as JSON, like `read` does.
- [commands/update.md](commands/update.md) — Change some fields of an entity, and print it as JSON, like `read` does.
- [commands/delete.md](commands/delete.md) — Remove an entity, and print its id.
