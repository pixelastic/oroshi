## PRD

[zshlint-precommit/PRD.md](./PRD.md)

## What to build

New yarn script `scripts/yarn/lint-zsh`, called by lint-staged with staged file paths as arguments. For each argument, calls `is-zsh` to determine if it is a ZSH file. Collects all ZSH files and calls `zshlint` once with all of them. Exits with zshlint's exit code — no JSON parsing. If no ZSH files are found among the arguments, exits 0 silently.

Update `lintstaged.config.js` to run both `test-bats` and `lint-zsh` for the same glob pattern, using an array.

## Acceptance criteria

- [ ] `scripts/yarn/lint-zsh` exists and is executable
- [ ] Calling `lint-zsh` with no arguments exits 0
- [ ] Calling `lint-zsh` with only non-ZSH file paths exits 0
- [ ] Calling `lint-zsh` with a ZSH file path that has violations exits 1
- [ ] Calling `lint-zsh` with a ZSH file path that has no violations exits 0
- [ ] `lintstaged.config.js` entry for `{scripts/bin,config/term/zsh}/**/*` is an array containing both `./scripts/yarn/test-bats` and `./scripts/yarn/lint-zsh`
- [ ] Staging a ZSH file with a zshlint violation and running `git commit` is blocked by the pre-commit hook

## Blocked by

- issue-003 (`is-zsh` must exist)
