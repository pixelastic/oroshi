# Service glossary

Each service has a glossary that defines its own vocabulary.

## Role

- Each service has one, in `<service>/__docs/GLOSSARY.md`.
- It uses the format of the [API glossary](../../GLOSSARY.md), and does not
  repeat it. A term of the API glossary is not defined again.
- It tells an agent how to name and call the commands of the service, without
  guessing.

## How to write it

Write the glossary with the `/glossary` skill. The skill sets the format, and
this page does not repeat it.

## Required content

Whatever the drill settles, the glossary must define these points:

- **Authentication**: the kind of the service, a key API or an OAuth API. An
  OAuth API needs a [`login`](../commands/login.md).
- **Entities**: one entry per entity. It says what the entity is in this
  service, whether its schema is fixed or open, and its anchor, if it has one
  (a table, a space).
- **Custom verbs**: one entry per [custom verb](../commands/custom.md), with
  what it does and on which entity. A service with no custom verb has none.
- **Service terms**: the words that a command, a flag or an error uses, and
  that could be confused with another (an id, a base, a space).
