## TLDR

Move `project/` autoload domain to `context/`, with `project/` as a subdomain.

## What to build

Rename `tools/term/zsh/config/functions/autoload/project/` to `tools/term/zsh/config/functions/autoload/context/`. Move `project-*` functions into `context/project/` subdirectory. `context-*` functions stay at `context/` root. Split `__tests__/` accordingly: context tests in `context/__tests__/`, project tests in `context/project/__tests__/`. Move `GLOSSARY.md` to `context/GLOSSARY.md` and update it to reflect the new domain hierarchy.

The `fpath` loader in `oroshi-reload-fpath.zsh` uses `**/*` glob, so adding a subdirectory requires no loading changes.

## Scaffolding Tests

All existing tests must pass from their new locations:
- `context-badge.bats`, `context-path.bats`, `context-root.bats` run from `context/__tests__/`
- `project-exists.bats`, `project-name.bats`, `project-path.bats`, `project-remove.bats`, `projects-build.bats` run from `context/project/__tests__/`

## Acceptance criteria

- [ ] `context/` directory exists with `context-badge`, `context-path`, `context-root`
- [ ] `context/project/` subdirectory exists with all `project-*` and `projects-*` functions
- [ ] `context/__tests__/` has context test files
- [ ] `context/project/__tests__/` has project test files
- [ ] `GLOSSARY.md` updated to reflect new domain structure
- [ ] Old `project/` directory no longer exists
- [ ] All existing tests pass
