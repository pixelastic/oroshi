## Guidance

- Lint-staged config: `lintstaged.config.js` at the repo root
- `is-js`, `is-bats`, `is-zsh` live in `tools/term/zsh/config/functions/autoload/term/`
- `git-file-lint` and `git-file-test` live in `tools/term/zsh/config/functions/autoload/git/file/`
- BATS tests for autoload functions live in `__tests__/` next to the function
- Prior art for `is-js` tests: `is-bats` and `is-zsh` test suites
- Testing zsh: `bats <filepath>`
- Linting zsh: `zsh-lint <filepath>`
- Linting js: `yarn run lint:fix <filepath>`
- `yarn run` resolves repo root automatically — no `cd` needed before calling it

## Discoveries
