## TLDR

Rename `PROJECTS_V2` → `PROJECTS` everywhere, and update `CONTEXT.md` to reference the new system.

## What to build

`PROJECTS_V2` carried a `_V2` suffix to avoid collision with the old `PROJECTS_INDEX` variable during the migration period. With issue 09 done, the old system is fully gone. Rename the associative array to `PROJECTS` across the entire codebase:

- `dist/projects.zsh` (the generated file — update `projects-build` to emit `PROJECTS`)
- `projects-load-definitions` (the loader function — both the `typeset` declaration and the idempotency check)
- All autoload functions that read from it: `project-exists`, `project-name`, `project-path`, `context-badge`, `context-root`, `yarn.zsh`, `complete-jumps`
- Any bats tests that reference `PROJECTS_V2` directly

Also update `CONTEXT.md` (the domain glossary in the project autoload directory): the definition of **Project** currently references `PROJECT_<KEY>_*` env vars in `env/projects.zsh`. Update it to reference the `PROJECTS` associative array in `dist/projects.zsh`.

## Acceptance criteria

- [ ] Issue 09 is complete
- [ ] No occurrence of `PROJECTS_V2` remains anywhere in the repo
- [ ] `projects-build` emits `typeset -gA PROJECTS` and `PROJECTS[...]` assignments
- [ ] `projects-load-definitions` declares and checks `PROJECTS`, not `PROJECTS_V2`
- [ ] All autoload functions reference `PROJECTS`, not `PROJECTS_V2`
- [ ] `CONTEXT.md` definition of **Project** references `dist/projects.zsh` and the `PROJECTS` associative array
