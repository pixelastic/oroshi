# API Helpers

An API helper is a command that talks to one web service (Airtable, Gmail,
Notion, Confluence, Make, …) and prints the result on stdout. Every helper has
the same three layers: a thin ZSH wrapper that forwards `"$@"`, a kebab-case
JavaScript bin that parses the arguments with `minimist`, and a camelCase
JavaScript module that calls the service and returns data. All helpers share
one command vocabulary, one argument convention and one output format, so that
humans and agents can guess how any service behaves.

## API shapes

A service follows one of two shapes. The exact definitions, and how to choose,
come with the command vocabulary.

- **Focused API** — one entity dominates and is left out of command names
  (`<service>-<action>`).
- **Composite API** — several entities, none dominant
  (`<service>-<entity>-<action>`).

## Detail files

- [architecture.md](architecture.md) — Where the code lives, how a service is configured and authenticated, and how it fails.
- [documentation.md](documentation.md) — How commands are documented
- [arguments.md](arguments.md) — How a command receives its arguments: positional or named, flag names, content, limit and accounts.
- [output.md](output.md) — What a command prints: the raw format, JSON, streams, and the `# Usage:`, `# Fields:` and `# Writes:` headers.
- [commands/list-raw.md](commands/list-raw.md) — Print the entities of a service as plain lines, one per line, for agents and scripts to parse.
- [commands/search.md](commands/search.md) — Find entities across a whole service and print them as rich JSON.
- [commands/read.md](commands/read.md) — Take the id of an entity, and print that entity as JSON.
