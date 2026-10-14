# Adding an API

Follow these steps, in order, to add the API helper of a new service. Each step
has a goal, an exit criterion and the actions. Do not start a step before the
exit criterion of the previous step is met.

## Step 1 — Write the glossary

**Goal:** Name everything the service contains before any other work.

**Exit criterion:** The glossary of the service exists and defines its
authentication kind, its entities, its custom verbs and its terms.

Write the glossary with the `/glossary` skill. It defines:

- the authentication kind of the service,
- its entities, each with a fixed or open schema (see
  [GLOSSARY.md](GLOSSARY.md)),
- its custom verbs,
- its terms ([reference/docs/glossary.md](reference/docs/glossary.md)).

## Step 2 — Validate the entities

**Goal:** Confirm that each entity and each field of the glossary exists in the
real API.

**Exit criterion:** The fields of each entity are confirmed by a real call.

- Read the documentation of the API of the service.
- Ask the user for the credentials early, so that real calls are possible.
- Confirm the fields of each entity against the real API.

## Step 3 — Validate the verbs

**Goal:** Know which commands each entity gets.

**Exit criterion:** The list of commands is written down, one command per
verb and per entity.

- For each entity, list every verb that the API allows
  ([reference/commands/README.md](reference/commands/README.md)).
- List a [custom verb](reference/commands/custom.md) for each action that is
  not CRUD.

## Step 4 — Validate the arguments

**Goal:** Fix the arguments of each command before writing code.

**Exit criterion:** Each command of step 3 has its arguments chosen.

Choose the arguments of each command with
[reference/commands/README.md](reference/commands/README.md) and
[arguments.md](arguments.md).

## Step 5 — Create the workspace

**Goal:** Have the scaffolding that every command needs.

**Exit criterion:** The workspace has its `package.json`, its `getConfig.js`
and its `callApi.js`.

- Create the `package.json` of the service ([architecture.md](architecture.md)).
- Create its [`getConfig.js`](reference/lib/getConfig.md).
- Create its [`callApi.js`](reference/lib/callApi.md).
- For an OAuth API, read [oauth.md](oauth.md) first. It changes both files and
  adds the command to log in.

## Step 6 — Allow the commands

**Goal:** Let Claude call the new commands without a permission prompt.

**Exit criterion:** Each command of step 3 is in
`tools/ai/claude/config/hooks/allow-list.json`.

Add every command of step 3 with `skills-allowlist-add <name>...`. Do not edit
`allow-list.json` by hand: the helper keeps it sorted. Add the commands as soon
as you create each one, so that Claude can test it without a permission prompt.

## Step 7 — Implement the commands

**Goal:** Have every command of step 3 working, documented and tested.

**Exit criterion:** Every command of step 3 is implemented, its header is
documented and its tests pass.

For each entity, implement the commands in this order, one at a time. Copy the
template of each verb:

1. [`search`](reference/commands/search.md), first: `list-raw` sits on top of
   it. Skip it only if the service has no endpoint to search the entities.
2. [`list-raw`](reference/commands/list-raw.md). Write its `# Fields:` header
   only with the fields confirmed in step 2.
3. [`list`](reference/commands/list.md)
4. [`read`](reference/commands/read.md)
5. [`create`](reference/commands/create.md)
6. [`update`](reference/commands/update.md)
7. [`delete`](reference/commands/delete.md)
8. a [custom verb](reference/commands/custom.md), for an action that is not
   CRUD.

For each entity, also create
[`format<Entity>.js`](reference/lib/formatEntity.md). It is a simple identity
pass-through by default and evolves only if needed.

For each command:

- Print the format described in its own file, for example
  [`list-raw`](reference/commands/list-raw.md#role).
- Document its header ([documentation.md](documentation.md)).
- Test it ([tests.md](tests.md)).

## Final checklist

- [ ] The glossary defines the authentication kind, the entities, the custom
      verbs and the terms.
- [ ] The fields of each entity are confirmed against the real API.
- [ ] The list of commands and their arguments is written down.
- [ ] The workspace has its `package.json`, `getConfig.js` and `callApi.js`.
- [ ] An OAuth API follows [oauth.md](oauth.md) and has its login command.
- [ ] `allow-list.json` has every command.
- [ ] Every entity has its `format<Entity>.js`.
- [ ] Every command prints its documented format.
- [ ] Every command has its documented header.
- [ ] Every command is tested.
