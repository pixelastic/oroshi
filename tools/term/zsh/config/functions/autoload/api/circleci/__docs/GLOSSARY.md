# CircleCI

The commands that let a shell or an agent read CircleCI (circleci.com)
**Projects**, **Runs** and **Logs**, and rerun a **Run**. It follows the
[API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

This glossary defines only what is custom to CircleCI. The base verbs (`list`,
`list-raw`, `search`, `read`, `create`, `update`, `delete`, `append`, `replace`
and `remove`) are defined in the API glossary and are not defined again here. Do
not add an entry for a base verb, even for a new command. The behavior of a
command belongs in the header of its wrapper.

## Language

### Authentication

CircleCI is a **Key API**. Its token is `CIRCLECI_TOKEN`, sent as
`Circle-Token: <token>`. There is no **Login**.

### Entities

**Project**:

A repository that CircleCI follows, identified by its **Slug**. It has no
**Anchor**, and has a **Fixed schema**.

_Avoid_: repository, repo

**Run**:

One execution of the CI of a **Project** for a commit, identified by a UUID that
already carries its **Project**. Its **Anchor** is `--project` for the commands
that search it, and it has a **Fixed schema**.

_Avoid_: pipeline, workflow, build, check

**Log**:

The output of every **Step** of every **Job** of one **Run**. It has no id of
its own, since its id is the id of its **Run**. It is read-only, and has a
**Fixed schema**.

_Avoid_: output, trace, console

### Custom verbs

**rerun**:

Starts a new attempt of a whole **Run**, from its id, and prints the **Run**. It
reruns every **Job**, and has no flag to rerun only the failed ones or one
**Job**.

_Avoid_: retry, restart, replay

### Service terms

**Slug**:

The identifier of a **Project**, written `gh/<org>/<repo>`, which `--project`
and `project-read` expect.

_Avoid_: project id, full name, repository name

**Job**:

One element of a **Run**, with a number, a name, a status and a duration. It has
no command of its own, and `run-read` lists the **Jobs** of a **Run**.

_Avoid_: build, task

**Step**:

One command executed by a **Job**, with its own status, duration and output. A
**Log** holds one entry per **Step**.

_Avoid_: action, command

## Departures from `docs/api/`

- `--status` of `run-search` and `run-list-raw` is applied after `--limit`.
  CircleCI has no status filter, and its pipelines endpoint ignores a `status`
  parameter. A result can hold fewer **Runs** than the limit, and a short result
  is not a complete one.
- `log-read` prints JSON like `read`, but its content is the raw text of the
  **Steps**, and its id is the id of another entity, the **Run**. A **Log** has
  no id, no `list` and no `search` of its own. CircleCI has no log endpoint, so
  the **Log** is built from the **Steps** of a **Run**, and only the **Run** can
  name it. Its positional argument also accepts a URL or the number of a **Job**
  (with `--project`), which it resolves to the **Run** and limits the **Log** to
  that **Job**.

## Flag convention

- The id of the entity read is positional. The **Anchors** and the filters are
  named.
- Example: `circleci-project-read gh/pixelastic/firost`. The **Slug** is
  positional.
- Example: `circleci-run-search --project gh/pixelastic/firost`. The **Anchor**
  `--project` is named, and `run-search` takes no positional query.

## Relationships

- A **Project** holds zero or more **Runs**
- A **Run** belongs to exactly one **Project**
- A **Run** holds one or more **Jobs**
- A **Job** holds zero or more **Steps**
- A **Log** belongs to exactly one **Run**, and holds the **Steps** of all its
  **Jobs**
- `rerun` applies to exactly one **Run**

## Flagged ambiguities

- "pipeline" and "workflow" are two levels of the CircleCI API that the user
  sees as one thing — resolved: the concept is a **Run**, enriched with the
  fields of its pipeline. Neither word names a command, a flag or an error.
- "job" is the name of an element of a **Run**, and of the unit that GitHub
  shows in a status — resolved: a **Job** is never an entity. The number of a
  **Job** and the number of a pipeline are two different counters.
- "log" is not an endpoint of CircleCI — resolved: a **Log** is built from the
  **Steps** of the **Jobs** of a **Run**, and the output of each **Step** is
  downloaded from a presigned URL.

## Example dialogue

> **Dev:** "The check of my pull request failed. How do I see why?" **Domain
> expert:** "Call `circleci-log-read` with the URL of the check. It prints the
> **Log** of the **Run**, one entry per **Step**." **Dev:** "Can I read only the
> **Job** that failed?" **Domain expert:** "Yes — a URL or a number of a **Job**
> limits the **Log** to it." **Dev:** "How do I retry a flaky failure?" **Domain
> expert:** "Call `circleci-run-rerun` with the id of the **Run**. It reruns
> every **Job**, so ask before you do."
