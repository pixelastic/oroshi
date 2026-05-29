## TLDR

Migrate `complete-jumps` from `project-key` + `PROJECT_*_ICON` env var to `PROJECTS_V2[$name:icon]`.

## What to build

`complete-jumps` feeds ZSH jump autocompletion. For each mark in `$MARKPATH`, it uses the mark name to look up the matching project icon via `project-key` + `PROJECT_<KEY>_ICON`. Replace this with:

1. A call to `projects-load-definitions` at the top of the function.
2. Direct array lookup: `PROJECTS_V2[${item:t}:icon]` using the mark name (tail of path) as-is.

No test changes needed.

## Acceptance criteria

- [ ] `complete-jumps` no longer calls `project-key`
- [ ] `complete-jumps` no longer reads `PROJECT_*_ICON` env vars
- [ ] `projects-load-definitions` is called before array access
- [ ] Icon lookup uses `PROJECTS_V2[${item:t}:icon]` directly
