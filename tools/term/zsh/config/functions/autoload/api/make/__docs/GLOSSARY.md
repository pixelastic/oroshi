# Make

The commands that let a shell or an agent read and write Make (make.com)
scenarios, folders and executions. It follows the
[API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

## Language

### Authentication

Make is a **Key API**. Its key is `MAKE_DOT_COM_API_KEY`, sent as
`Authorization: Token <key>`, not `Bearer`. There is no **Login**.

**Zone**:

The datacenter of the account, a short code such as `eu2` (`MAKE_DOT_COM_ZONE`),
which gives the host `eu2.make.com`.

_Avoid_: region, datacenter, host

**Organization**:

The level of Make above a **Team**. No command reads it or takes it as a flag.

_Avoid_: company, account, workspace

**Team**:

The Make team that holds the **Scenarios** and **Folders**, identified by
`MAKE_DOT_COM_TEAM_ID`. `getConfig` is its only source, and no command takes
`--teamId`.

_Avoid_: organization, workspace, account

### Entities

**Scenario**:

An automation of Make, identified by a number. It has no **Anchor**, and has a
**Fixed schema**.

_Avoid_: workflow, automation, flow

**Folder**:

A named container of **Scenarios**, identified by a number. It has no
**Anchor**, and has a **Fixed schema**.

_Avoid_: directory, project, group

**Execution**:

One run of a **Scenario**, identified by a string. Its **Anchor** is
`--scenarioId`, and it has a **Fixed schema**.

_Avoid_: log, run, history

### Custom verbs

**enable**:

Puts a **Scenario** in service, so that Make runs it according to its
**Scheduling**.

_Avoid_: activate, start

**disable**:

Takes a **Scenario** out of service.

_Avoid_: deactivate, stop, pause

**run**:

Starts one **Execution** of an **Enabled** **Scenario** right away, and fails on
a **Disabled** one. It prints the execution ID, or with `--wait` the whole
response of Make: execution ID, status and outputs.

_Avoid_: start, trigger, execute

### Service terms

**Enabled**:

The state of a **Scenario** that `enable` put in service, which Make calls
`isActive`.

_Avoid_: active, running, on

**Disabled**:

The state of a **Scenario** that is out of service, which is also the state
after `create`.

_Avoid_: inactive, paused, stopped, off

**Blueprint**:

The JSON that describes the modules and the flow of a **Scenario**, given with
`--blueprint-file`.

_Avoid_: definition, flow, template

**Validation**:

The local check of a **Blueprint** that `create` and `update` run before any
request. It lists every problem at once, and fails with
`MAKE_BLUEPRINT_INVALID`. It has no bypass. Make has no validate endpoint, and
its `isinvalid` field is only known after the request.

**Alignment**:

The layout that `create` and `update` give to the modules of a **Blueprint**
before the save: one baseline, left to right, with routes stacked around their
router. It has no bypass.

**Backup**:

The file where `update` writes the previous **Blueprint** in a temporary
directory before it saves a new one.

**Rollback**:

The step where `update` sends the **Backup** back when Make marks the new
**Blueprint** as `isinvalid`. The command then fails with
`MAKE_BLUEPRINT_INVALID`, or names the **Backup** when the rollback fails.

_Avoid_: lint, verification, dry run

**Scheduling**:

The JSON that says when Make runs an **Enabled** **Scenario**, given with
`--scheduling-file`, and `on-demand` by default.

_Avoid_: schedule, cron, interval

**Trigger**:

The first module of a **Blueprint**, which says what starts the **Scenario** (a
webhook, a watch).

_Avoid_: hook, start

**Status**:

The result of an **Execution**, as Make returns it (`success`, `warning`,
`error`).

_Avoid_: state, result, outcome

**Subfolder**:

A **Folder** placed inside another **Folder**, its **Parent folder**.

_Avoid_: child folder, nested folder

**Parent folder**:

The **Folder** that holds a **Subfolder**, given with `--parentFolderId` to
`create` and `update`. A top-level **Folder** has none.

_Avoid_: parent, parent id, container

**Empty folder**:

A **Folder** with no **Scenario** and no **Subfolder**.

_Avoid_: unused folder, clean folder

## Flagged omissions

- `read` of a **Folder** returns its main fields, its **Subfolders** and its
  direct **Scenarios**, never the **Scenarios** of its **Subfolders**.
- `delete` of a **Folder** only removes an **Empty folder**, and fails with
  `MAKE_FOLDER_NOT_EMPTY` otherwise. The API alone would delete the
  **Subfolders** and move the **Scenarios** to the **Parent folder**, so the
  command checks first.

## Flag convention

- The ID of the entity read is positional. The **Anchors** and the filters are
  named.
- The **Anchor** stays named when the positional argument is a text query.
- Example: `make-execution-read <executionId> --scenarioId <id>`. The
  **Execution** ID is positional, and its **Anchor** `--scenarioId` is named.
- Example: `make-scenario-list "sync" --folderId 399268`. The text query is
  positional, and the filter `--folderId` is named.

## Relationships

- A **Team** belongs to one **Organization**, and holds zero or more
  **Scenarios** and **Folders**
- A **Folder** holds zero or more **Scenarios** and zero or more **Subfolders**
- A **Subfolder** has exactly one **Parent folder**
- A **Scenario** is in at most one **Folder**
- A **Scenario** has exactly one **Blueprint** and one **Scheduling**, and is
  **Enabled** or **Disabled**
- A **Blueprint** has at most one **Trigger**
- A **Scenario** has zero or more **Executions**, each with one **Status**
- Every command uses the same key, **Zone** and **Team**

## Flagged ambiguities

- "team" and "organization" are two levels of Make — resolved: the **Team**
  holds the data and its ID is the only one read, and the **Organization** is
  never read.
- "log" is the name of an **Execution** in the Make API — resolved: the concept
  is an **Execution**, and `logs` is only the path of the API.
- "start" and "stop" are the names of `enable` and `disable` in the Make API —
  resolved: the concepts are `enable` and `disable`, since `start` suggests an
  **Execution**.
- "scheduling" and "trigger" are not the same thing — resolved: the **Trigger**
  is a module of the **Blueprint**, and the **Scheduling** is the setting of the
  **Scenario** that says when Make runs it. A webhook **Scenario** has the
  `on-demand` **Scheduling**.
- "parent" can name several hierarchies of Make — resolved: only the **Parent
  folder** exists here, and its flag is `--parentFolderId`.

## Example dialogue

> **Dev:** "I want to run my **Scenario** every hour. Do I call
> `make-scenario-run`?" **Domain expert:** "No — `run` starts one **Execution**
> only. Give a **Scheduling** with `--scheduling-file`, then call
> `make-scenario-enable`." **Dev:** "How do I see what happened last night?"
> **Domain expert:** "Call `make-execution-list` with `--scenarioId`. Each
> **Execution** has a **Status**." **Dev:** "Can I delete the **Folder** of the
> old **Scenarios**?" **Domain expert:** "Only if it is an **Empty folder**.
> Move or delete its **Scenarios** and **Subfolders** first, or the command
> fails."
