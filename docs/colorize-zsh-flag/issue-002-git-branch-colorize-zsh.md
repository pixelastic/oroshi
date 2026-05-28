## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Add a `--zsh` flag to `git-branch-colorize` and propagate it to every `colorize` call.

`git-branch-colorize` calls `colorize` ~8 times (one per return branch). Each call must receive `--zsh` when the flag is passed to the parent function. Pattern: `zparseopts` receives `--zsh`, build `local -a zshFlag=(); (( isZsh )) && zshFlag=(--zsh)`, and every `colorize` call receives `"${zshFlag[@]}"`.

## Acceptance criteria

- [ ] `git-branch-colorize main` produces ANSI output (contains `\e[`)
- [ ] `git-branch-colorize main --zsh` produces zsh prompt output (contains `%F{`)
- [ ] `git-branch-colorize --with-icon --zsh` produces output with icon and `%F{`
- [ ] `git-branch-colorize --with-icon --zsh` contains no `\e[`
- [ ] Bats tests pass: `config/term/zsh/functions/autoload/git/branch/__tests__/git-branch-colorize.bats`

## Blocked by

- issue-001 (`colorize` must support `--zsh`)
