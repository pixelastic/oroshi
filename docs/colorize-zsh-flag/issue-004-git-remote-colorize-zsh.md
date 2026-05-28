## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Add a `--zsh` flag to `git-remote-colorize` and propagate it to every `colorize` call.

Same pattern as issue-002: `zparseopts` receives `--zsh`, build `zshFlag`, propagate to `colorize`.

## Acceptance criteria

- [ ] `git-remote-colorize origin` produces ANSI output (contains `\e[`)
- [ ] `git-remote-colorize origin --zsh` produces zsh prompt output (contains `%F{`)
- [ ] `git-remote-colorize --with-icon --zsh` produces output with icon and `%F{`
- [ ] `git-remote-colorize origin --zsh` contains no `\e[`
- [ ] Bats tests pass: `config/term/zsh/functions/autoload/git/remote/__tests__/git-remote-colorize.bats`

## Blocked by

- issue-001 (`colorize` must support `--zsh`)
