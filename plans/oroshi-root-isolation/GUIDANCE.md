## Guidance

### Testing commands

- Run a single bats file: `bats <filepath>`
- Lint a bats file: `bats-lint <filepath>`
- Lint a zsh file: `zsh-lint <filepath>`

### Key files (relative to repo root)

- Bats helper: `tools/term/bats/config/helper`
- zshenv: `tools/term/zsh/config/zshenv.zsh`
- zshenv tests: `tools/term/zsh/config/__tests__/zshenv.bats`
- Lint rule: `scripts/bin/term/bats/bats-lint/__rules/rule-no-run-zsh.zsh`
- Lint rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-run-zsh.bats`

### Conventions

- `bats_mock_oroshi_root` writes to `mock.zsh` — same file as `bats_mock`. They compose.
- Tests create their own fixture directories in the mock root (`mkdir -p` + `cp`). No convenience helper.
- The `_MOCK` suffix signals a variable exists solely for test injection.
- The execution order in `bats_run_zsh` subprocess is: `.zshenv` -> `mock.zsh` -> function under test.
- When editing bats helper, preserve existing comments. When deleting code, delete its comments with it.

### Prior art

- `icons-load-definitions.bats` — config mock pattern (issue 01 migrates this)
- `post-commit.bats` — function mock pattern with `bats_mock`
- `path.bats` — inline script pattern for infra tests (category A)

## Discoveries
