## TLDR

Migrate `colors-refresh` to call `projects-build` instead of `env-generate-projects`, and force-reload `PROJECTS_V2` in the current session.

## What to build

`colors-refresh` currently calls `env-generate-projects` then sources `env/projects.zsh` to rebuild and reload the old project env vars. Replace with:

1. Call `projects-build` to regenerate `dist/projects.zsh` from the source of truth.
2. `unset PROJECTS_V2` to invalidate the stale in-memory associative array.
3. Call `projects-load-definitions` to reload from the freshly generated file.

The explicit `unset` + `projects-load-definitions` pair makes the intent visible when reading the script: this is a real refresh, not a lazy load.

Remove the `env-generate-projects` call and the `source env/projects.zsh` line. Do not yet delete the `env-generate-projects` script or the generated env files — that happens in issue 09.

No test changes needed.

## Acceptance criteria

- [ ] `colors-refresh` no longer calls `env-generate-projects`
- [ ] `colors-refresh` no longer sources `env/projects.zsh`
- [ ] `colors-refresh` calls `projects-build`
- [ ] `colors-refresh` calls `unset PROJECTS_V2` followed by `projects-load-definitions`
