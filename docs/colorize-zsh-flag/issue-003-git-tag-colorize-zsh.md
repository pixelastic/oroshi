## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Add a `--zsh` flag to `git-tag-colorize` and propagate it to every `colorize` call.

Same pattern as issue-002: `zparseopts` receives `--zsh`, build `zshFlag`, propagate to `colorize`.

## Acceptance criteria

- [ ] `git-tag-colorize v1.0` produces ANSI output (contains `\e[`)
- [ ] `git-tag-colorize v1.0 --zsh` produces zsh prompt output (contains `%F{`)
- [ ] `git-tag-colorize --with-icon --zsh` produces output with icon and `%F{`
- [ ] `git-tag-colorize v1.0 --zsh` contains no `\e[`
- [ ] Bats tests pass: `config/term/zsh/functions/autoload/git/tag/__tests__/git-tag-colorize.bats`

## Blocked by

- issue-001 (`colorize` must support `--zsh`)
