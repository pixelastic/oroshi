## Guidance

### Goal

Wire Python into the dirty-file lint/test pipeline (`vfl`/`vft`) and pre-commit lint-staged hook, matching how ZSH and JS are already handled.

### Testing commands

- ZSH/BATS: `bats <filepath>`
- JS: `yarn run test <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- BATS lint: `bats-lint <filepath>`
- JS lint: `yarn run lint:fix <filepath>`

### File locations (relative to repo root)

- New autoload function: `tools/term/zsh/config/functions/autoload/term/python/is-python`
- New script: `scripts/bin/python/python-test-path`
- Extended script: `scripts/bin/python/python-lint`
- Modified pipeline: `tools/term/zsh/config/functions/autoload/git/file/git-file-lint`
- Modified pipeline: `tools/term/zsh/config/functions/autoload/git/file/git-file-test`
- New yarn wrappers: `scripts/yarn/lint-python`, `scripts/yarn/test-python`
- Modified yarn wrapper: `scripts/yarn/lint-zsh`
- Config: `lintstaged.config.js`, `package.json`

### Conventions

- Autoload functions use `setopt local_options err_return` (not `set -e`)
- Scripts with a shebang use `set -e`
- ZSH flag tests use `[[ $isXxx == "1" ]]` not `(( isXxx ))`
- Use `[[ ... ]] && return 0` early-return pattern
- Use `$OROSHI_ROOT` not hardcoded `~/.oroshi`
- Bats tests: use `bats_run_zsh`, `bats_mock`, variables in `setup()`

### Prior art

- `is-js` → model for `is-python` (simpler — no shebang branch needed)
- `bats-test-path` → model for `python-test-path`
- `scripts/yarn/lint-zsh` → model for `scripts/yarn/lint-python`
- `scripts/yarn/test-bats` → model for `scripts/yarn/test-python`
- `tools/term/zsh/config/functions/autoload/term/js/__tests__/is-js.bats` → prior art for `is-python` tests
- `scripts/bin/term/bats/__tests__/bats-test-path.bats` → prior art for `python-test-path` tests
- `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-lint.bats` → prior art for issue 04 tests
- `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-test.bats` → prior art for issue 05 tests

### Python test naming convention

Confirmed by existing test: `tools/term/kitty/config/__tests__/test_tab_bar.py`
Convention: `__tests__/test_{basename_without_extension}.py`

## Discoveries

(append after each issue)
