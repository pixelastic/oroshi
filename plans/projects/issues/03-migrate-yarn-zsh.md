## TLDR

Migrate `oroshi-prompt-populate:yarn_link` in `yarn.zsh` from `project-key` + `PROJECT_*_ICON` env var to `PROJECTS_V2[$name:icon]`.

## What to build

The yarn link prompt segment iterates yarn-linked packages and displays the icon of the matching project for each one. It currently converts each package name to an env var key via `project-key`, then reads `PROJECT_<KEY>_ICON`.

Replace this with:
1. A call to `projects-load-definitions` at the top of the function (idempotent — safe to call in async prompt context).
2. Direct array lookup: `PROJECTS_V2[$linkName:icon]` using the package name as-is.

No test changes needed.

## Acceptance criteria

- [ ] `oroshi-prompt-populate:yarn_link` no longer calls `project-key`
- [ ] `oroshi-prompt-populate:yarn_link` no longer reads `PROJECT_*_ICON` env vars
- [ ] `projects-load-definitions` is called before array access
- [ ] Icon lookup uses `PROJECTS_V2[$linkName:icon]` directly
