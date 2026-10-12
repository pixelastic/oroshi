# Commands

Every command of an API helper is named after one verb of a closed vocabulary.
This file lists them all, with what each one does.

## Vocabulary

The vocabulary is closed: a command is named after one of these verbs.

| Verb                        | Role                                              |
|-----------------------------|---------------------------------------------------|
| [`list`](list.md)           | Print the entities as a colored table, for humans |
| [`list-raw`](list-raw.md)   | Print the entities as `▮` lines, for agents       |
| [`search`](search.md)       | Find entities of one type, as rich JSON           |
| [`read`](read.md)           | Print one entity, by its id, as JSON              |
| [`create`](create.md)       | Make a new entity, and print it as JSON           |
| [`update`](update.md)       | Change some fields of an entity, and print it     |
| [`delete`](delete.md)       | Remove an entity, and print its id                |


If the API doesn't offer a way to perform certain verbs (like an `update` on a
read-only `log`), then that command is not implemented.

### Custom verbs

A service may also have needs of its own, with its own verbs: `activate` or
`run` when an action is not CRUD. A [custom verb](custom.md) never replaces a
verb of the table.

The words used here (service, entity, command, verb) are defined in the
[glossary](../../GLOSSARY.md).

## Allow-list

Every command is a helper. Add each one to the Claude allow-list with
`skills-allowlist-add <name>` before creating it, so that Claude can test it
without a permission prompt. See
[Adding an API](../../README.md#adding-an-api).
