## Guidance

### Testing commands

- ZSH tests: `bats <filepath>`
- JS tests: `yarn run test <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`
- JS lint: `yarn run lint:fix <filepath>`

### File locations (relative to repo root)

- ZSH commit aliases: `tools/term/zsh/config/aliases/git/commit.zsh`
- ZSH autoload commit functions: `tools/term/zsh/config/functions/autoload/git/commit/`
- ZSH autoload commit tests: `tools/term/zsh/config/functions/autoload/git/commit/__tests__/`
- git-commit-message scripts: `scripts/bin/git/commit/git-commit-message/`
- git-commit-message JS tests: `scripts/bin/git/commit/git-commit-message/__tests__/`
- TODO file: `TODO.md` (line 42 has the vcaa entry)

### Conventions

- ZSH autoload functions use `setopt local_options err_return` (not `set -e`)
- ZSH scripts with shebang use `set -e`
- Repo arg convention: first positional arg if slot is free, `--repo` flag if first positional is taken
- `Gilmore(repoPath)` already accepts optional root path — no Gilmore changes needed
- Bats tests use `bats_mock` for stubbing collaborators, `bats_run_zsh` for running functions
- JS tests use vitest with `vi.mock('gilmore')` pattern

### Prior art

- `git-commit-create-all` + its bats tests: pattern for `--repo` threading in ZSH
- `getDiff` JS tests: pattern for mocking Gilmore in vitest

## Discoveries
