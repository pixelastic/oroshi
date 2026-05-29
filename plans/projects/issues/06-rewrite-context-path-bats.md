## TLDR

Rewrite the broken `context-path.bats` tests to use the bats mock pattern instead of old env var injection.

## What to build

The existing `context-path.bats` tests inject `PROJECTS_INDEX_BY_PATH` and `PROJECT_*` env vars into a `zsh -c` subshell. This no longer works: `context-path` → `context-root` → `project-name` now reads from `PROJECTS_V2`. The tests are currently failing.

Rewrite all three tests following the `context-root.bats` pattern:
- Use `bats_run_function` instead of `run zsh -c`
- Mock `projects-load-definitions` as a no-op via `bats_mock`
- Populate `PROJECTS_V2` directly inside the test (the mock prevents it being overwritten by the real loader)
- Mock `context-root` to return controlled values (since `context-path` delegates root resolution to it)

The three scenarios to cover: path inside a project, path at project root, path outside all projects.

## Acceptance criteria

- [ ] All three `context-path.bats` tests are rewritten using `bats_run_function` + bats mock
- [ ] No test injects `PROJECTS_INDEX_BY_PATH` or `PROJECT_*` env vars
- [ ] `bats context-path.bats` passes
