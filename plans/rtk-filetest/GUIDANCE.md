## Guidance

- **Test command:** `bats tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-test.bats`
- **Lint command:** `zsh-lint tools/term/zsh/config/functions/autoload/git/file/git-file-test`
- **Production file:** `tools/term/zsh/config/functions/autoload/git/file/git-file-test`
- **Test file:** `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-test.bats`
- **Claude detection:** `is-claude` function checks `CLAUDECODE=1` env var
- **RTK prefix pattern:** `rtk bin-zsh <cmd>` — used for ZSH autoloaded functions that RTK can't call directly
- **Mocking convention:** Use `bats_mock` to register function overrides in tests
- **Prior art:** See existing tests in `git-file-test.bats` for mocking `bats`, `yarn`, `python-test`, `bats-test-path`

## Discoveries
