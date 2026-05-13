# claude-sandbox

Runs Claude Code in an isolated Docker container scoped to a single directory, with full permissions but no write access outside that directory.

## Language

**sandbox**:
A Docker container invocation where Claude operates with full permissions but filesystem writes are limited to the workspace.
_Avoid_: isolated session, container session

**workspace**:
The host directory mounted into the sandbox — the only place Claude can read and write.
_Avoid_: directory, project, mount path

**image**:
The pre-built Docker image containing Claude Code and its dependencies, tagged by Claude version and Node version.
_Avoid_: container, environment

**agent user**:
The Linux user inside the container, whose UID/GID are aligned to the host user at build time so that files Claude creates belong to the host user.
_Avoid_: container user, docker user

**parent git**:
The `.git/` directory of the main repo when the workspace is a git worktree. Mounted read-only at its original host path so git references resolve correctly inside the container.
_Avoid_: git root, repo git

**auto-build**:
The behaviour where the required image is built automatically on first use if it doesn't exist yet.
_Avoid_: lazy build, on-demand build

## Relationships

- A **sandbox** mounts exactly one **workspace**
- A **sandbox** runs from exactly one **image**
- An **image** is tagged with one Claude version and one Node version
- If the **workspace** is a git worktree, the **sandbox** also mounts its **parent git**
- The **agent user** inside the sandbox has the same UID/GID as the host user

## Example dialogue

> **Dev:** "I want to test a skill on the `firost` worktree."
> **Domain expert:** "Run `claude-sandbox` from that worktree — it creates a **sandbox** with that directory as the **workspace**. Claude has full permissions inside it but can't touch anything else."
> **Dev:** "Does it need a running container or something?"
> **Domain expert:** "No. Each invocation is a fresh **sandbox** from the cached **image**. If the right **image** doesn't exist yet, **auto-build** creates it."

## Flagged ambiguities

- "container" was used loosely to mean both the running instance and the image — resolved: **sandbox** = running instance, **image** = the built artifact.
