# API Glossary

The words used across `docs/api/`. Every doc uses these terms, and no others.

This file holds the generic rules. The exceptions are defined in the files of
the commands concerned.

## Language

**Service**:

The top-level web API that helpers talk to (Airtable, Gmail, Notion, Make,
etc.).

_Avoid_: domain, subdomain, provider, integration

**Entity**:

What a service manages (a record, a page, a scenario). It is the unit that
commands list, read and change.

_Avoid_: object, item, resource

**Command**:

An executable named after one service, one entity and one verb, that a human or
an agent runs from the shell (`<service>-<entity>-<action>`).

_Avoid_: script, function, tool, bare helper

**API helper**:

The set of commands of one service.

_Avoid_: integration, client

**Key API**:

A service that authenticates with a key or a token kept in the config. It has no
**Login**. Examples: Notion and Make.

_Avoid_: token API

**OAuth API**:

A service that authenticates with OAuth tokens, granted by the user in a
browser. It gets them with a **Login**. Examples: Gmail and Confluence.

_Avoid_: grant API

**Login**:

The command of an **OAuth API**. It opens the browser, gets the tokens and saves
them. See [reference/commands/login.md](reference/commands/login.md).

_Avoid_: `auth`, `connect`, `signin`

**Positional argument**:

An argument given by its place on the command line. A command has at most one,
for the main input: an id, a query, or the content.

_Avoid_: bare argument, free argument

**Named argument**:

An argument given by a flag (`--limit 10`, `--pageId 1f3a`). Anchors are always
named. Filters are named too.

_Avoid_: option, switch, parameter

**Anchor**:

When an id is not enough to uniquely identify an entity, an anchor is needed
(like a table, a workspace, etc).

_Avoid_: scope, context

**Fixed schema**:

An entity whose fields are known in advance. Example: Confluence pages have
exactly a title and a body.

_Avoid_: strict schema

**Open schema**:

An entity whose fields depend on the data. Example: an Airtable record has a
different shape depending on its table.

_Avoid_: loose schema, free schema

**Wrapper**:

The thin ZSH file of a command, an autoloaded function found in `$fpath`. It
calls the bin.

_Avoid_: alias, launcher

**Bin**:

The JavaScript file that parses the arguments with `parseBinArgs`, calls the
module and prints the result.

_Avoid_: binary, CLI

**Module**:

The JavaScript file that holds the logic of a command. It takes one options
object as input, which the **Bin** fills from the **Positional argument** and
the **Named arguments**. Returns data but prints nothing.

_Avoid_: handler, controller

## Verbs

The closed vocabulary of commands. A service implements only the verbs it needs.
See [reference/commands/README.md](reference/commands/README.md) for the table
with links.

The glossary of a service does not define these verbs again. It defines only its
**Custom verbs**.

**[`list`](reference/commands/list.md)**:

Print the entities as a colored table, for humans.

_Avoid_: `ls`, `show`, `inbox`

**[`list-raw`](reference/commands/list-raw.md)**:

Print the entities as `▮`-separated lines, id first, for agents and scripts.

_Avoid_: `list --raw`, `dump`

**[`search`](reference/commands/search.md)**:

Find entities of one type, as rich JSON.

_Avoid_: `find`, `query`

**[`read`](reference/commands/read.md)**:

Print one entity, from its id, as JSON.

_Avoid_: `get`, `fetch`, `show`

**[`create`](reference/commands/create.md)**:

Make a new entity, and print it as JSON.

_Avoid_: `add`, `new`, `write`

**[`update`](reference/commands/update.md)**:

Change some fields of an entity, and print it as JSON. Only the given fields
change.

_Avoid_: `edit`, `set`, `write`

**[`delete`](reference/commands/delete.md)**:

Remove an entity, and print its id.

_Avoid_: `remove`, `destroy`

**Custom verb**:

A verb outside the closed vocabulary, for an action that is not CRUD. Example:
`activate`, `run`, `enable`. See
[reference/commands/custom.md](reference/commands/custom.md).

_Avoid_: service verb

## Relationships

- A **Service** manages one or more **Entities**.
- A **Service** is either a **Key API** or an **OAuth API**.
- An **OAuth API** has a **Login**. A **Key API** has none.
- A **Command** applies one verb to one **Entity**.
- An **API helper** is made of the **Commands** of one **Service**.
- A **Command** is made of a **Wrapper**, a **Bin** and a **Module**.
- A **Command** takes at most one **Positional argument**, and any number of
  **Named arguments**.

## Flagged ambiguities

- A **Custom verb** is not a new kind of **Command**. It is named
  `<service>-<entity>-<action>`, like the others, and never replaces a verb of
  the closed vocabulary.
- Some **Entities** of a given **Service** can have a **Fixed schema** while
  others can have an **Open schema**.
