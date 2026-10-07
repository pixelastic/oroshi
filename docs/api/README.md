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

- [commands/list-raw.md](commands/list-raw.md) — Print the entities of a service as plain lines, one per line, for agents and scripts to parse.

## Adding an API

Follow these steps in order.

1. Add the commands, starting with `list-raw`: [commands/list-raw.md](commands/list-raw.md).
