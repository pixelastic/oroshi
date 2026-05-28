## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Rewrite `context-badge` to call `colorize` directly for each colored segment, and rewrite its bats tests to use the `PROJECTS` associative array.

Remove the internal `_badge` and `_trailing_arrow` helpers. Build `local -a zshFlag=(); (( isZsh )) && zshFlag=(--zsh)` and call `colorize` for each segment: Project Badge, transition arrow (worktree only), Worktree Badge, and trailing arrow. Read project data from `PROJECTS[${projectName}.background.ansi]`, `.foreground.ansi`, `.icon`, `.hideNameInPrompt`.

The existing test file uses the old `PROJECT_<KEY>_*` env var format — rewrite it entirely to inject a `PROJECTS` associative array, following the same pattern as `context-project.bats`.

## Acceptance criteria

- [ ] `context-badge /path/in/project` produces output containing the project name
- [ ] `context-badge /path/in/project` produces no branch name for the main repo
- [ ] `context-badge /path/in/worktree` produces output containing the worktree branch name
- [ ] `context-badge my-project` (name arg) produces the same output as `context-badge /project/root/path`
- [ ] `context-badge /unknown/path` produces empty output
- [ ] Without `--zsh`: output contains `\e[`, no `%K{`
- [ ] With `--zsh`: output contains `%K{`, no `\e[`
- [ ] `_badge` and `_trailing_arrow` no longer appear in the source file
- [ ] Bats tests pass: `config/term/zsh/functions/autoload/project/__tests__/context-badge.bats`

## Blocked by

- issue-001 (`colorize` must support `--zsh` and `print -n`)
