## TLDR

Migrate `project-exists` from `PROJECTS_INDEX` env var loop to `PROJECTS_V2` associative array, and write bats tests.

## What to build

`project-exists` currently iterates `PROJECTS_INDEX` (a space-separated string of uppercase env var keys) and calls `project-key` to convert the input name to a key for comparison. Rewrite it to:

1. Call `projects-load-definitions` to ensure `PROJECTS_V2` is loaded.
2. Check whether the `:icon` key exists for the given project name in `PROJECTS_V2`. A project is considered registered if and only if its icon entry is present — color-only entries (like `dashboards`) have no icon and are not considered real projects.

Write new bats tests following the `context-root.bats` pattern: mock `projects-load-definitions` as a no-op, populate `PROJECTS_V2` directly in each test, and assert exit codes.

## Acceptance criteria

- [ ] `project-exists` no longer references `PROJECTS_INDEX` or `project-key`
- [ ] `project-exists "aberlaas"` returns exit 0 when `PROJECTS_V2[aberlaas:icon]` is set
- [ ] `project-exists "unknown"` returns exit 1 when no matching icon key exists
- [ ] `project-exists "dashboards"` returns exit 1 (color-only entry, no icon)
- [ ] Bats tests cover all three cases and pass
