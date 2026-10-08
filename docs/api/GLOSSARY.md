# API Glossary

The words used across `docs/api/`. Every doc uses these terms, and no others.

## Language

**Service**:
The top-level web API that helpers talk to (Airtable, Gmail, Notion, Make, etc).
_Avoid_: domain, subdomain, provider, integration

**Entity**:
What a service manages (a record, a page, a scenario). It is the unit that
commands list, read and change.
_Avoid_: object, item, resource

**Command**:
An executable named after one service and one verb, that a human or an agent
runs from the shell (`<service>-<entity>-<action>`).
_Avoid_: script, function, tool, bare helper

**API helper**:
The set of commands of one service.
_Avoid_: integration, client

**Focused API**:
A service where one entity clearly dominates. The entity is left out of the
command names (`<service>-<action>`) and of its module names (`listRaw.js`).
Secondary entities keep long names.
Examples: Gmail (messages) and Confluence (pages).
_Avoid_: simple API

**Composite API**:
A service with several entities, none dominant. Every command is named
`<service>-<entity>-<action>`.
Examples: Airtable (records, tables) and Make (scenarios, connections).
_Avoid_: multi-entity API

**Positional argument**:
An argument given by its place on the command line. A command has at most one,
and it is the one required argument: an id, a query, or the content.
_Avoid_: bare argument, free argument

**Named argument**:
An argument given by a flag (`--limit 10`, `--pageId 1f3a`). Optional arguments
and anchors are always named.
_Avoid_: option, switch, parameter

**Anchor**:
The optional parent an entity needs to be reached (a table, a space).
_Avoid_: scope, context

**Fixed schema**:
An entity whose fields are known in advance.
Example: Confluence pages have exactly a title and a body.
_Avoid_: strict schema

**Open schema**:
An entity whose fields depend on the data.
Example: an Airtable record has a difference shape depending on its table.
_Avoid_: loose schema, free schema


## Verbs

The closed vocabulary of commands. A service implements only the verbs it
needs. See [commands/README.md](commands/README.md) for the table with links.

**`list`**:
Print the entities as a colored table, for humans.
_Avoid_: `ls`, `show`, `inbox`

**`list-raw`**:
Print the entities as `▮`-separated lines, id first, for agents and scripts.
_Avoid_: `list --raw`, `dump`

**`search`**:
Find entities across the whole service, as rich JSON.
_Avoid_: `find`, `query`

**`read`**:
Print one entity, from its id, as JSON.
_Avoid_: `get`, `fetch`, `show`

**`create`**:
Make a new entity, and print it as JSON.
_Avoid_: `add`, `new`, `write`

**`update`**:
Change some fields of an entity, and print it as JSON. Only the given fields
change.
_Avoid_: `edit`, `set`, `write`

**`delete`**:
Remove an entity, and print its id. It exists only where a service needs it.
_Avoid_: `remove`, `destroy`

**Service verb**:
A verb outside the closed vocabulary, for an action that is not CRUD
Example: `activate`, `run`, `enable`
_Avoid_: custom verb

## Relationships

- A **Service** manages one or more **Entities**.
- A **Command** applies one verb to one **Entity**, or to the dominant
  **Entity** of a **Focused API**.
- An **API helper** is made of the **Commands** of one **Service**.
- A **Command** takes at most one **Positional argument**, and any number of
  **Named arguments**.

## Flagged ambiguities

- The shape of a service (Focused/Composite API) is chosen when it is created.
  When a second entity of a **Focused API** grows as important as the
  first, the service becomes **Composite**: rename its commands and modules to
  carry the entity.
- Some **Entities** of a given **Service** can have a **Fixed schema** while
  others can have an **Open schema**/
