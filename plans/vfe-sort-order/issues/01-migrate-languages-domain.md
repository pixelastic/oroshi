## TLDR

Move all language-specific autoload functions into `autoload/_languages/<lang>/`, convert `bats-test-path` and `python-test-path` from scripts to autoload functions, delete emptied directories.

## What to build

Create `autoload/_languages/` with subdirectories `javascript/`, `python/`, `bats/`, `zsh/`.

Migrate functions and their colocated `__tests__/` directories:

- `autoload/term/js/` → `_languages/javascript/` (is-js + test)
- `autoload/term/python/` → `_languages/python/` (is-python + test)
- `autoload/term/bats/` → `_languages/bats/` (is-bats, bats-test-list-raw, bats-fixture-function-* + tests)
- `autoload/term/zsh/` → `_languages/zsh/` (is-zsh, is-zsh-autoload-function + tests)
- `autoload/js/` → `_languages/javascript/` (eslintd-restart, js-pretty)
- `autoload/python/` → `_languages/python/` (pip-list, pip-list-raw, pip-package-colorize, pip-update + test)

Migrate scripts to autoload functions:

- `scripts/bin/term/bats/bats-test-path` → `_languages/bats/bats-test-path` (convert `set -e` → `setopt local_options err_return`, `exit 1` → `return 1`, remove shebang)
- `scripts/bin/python/python-test-path` → `_languages/python/python-test-path` (same conversion)
- Move their `__tests__/` directories alongside

Delete all emptied source directories: `autoload/term/js/`, `autoload/term/python/`, `autoload/term/bats/`, `autoload/term/zsh/`, `autoload/js/`, `autoload/python/`, `scripts/bin/term/bats/bats-test-path` and its test, `scripts/bin/python/python-test-path` and its test.

## Scaffolding Tests

Verify structural transformation:
- Functions exist at new `_languages/` paths
- Old `autoload/term/<lang>/` directories no longer exist
- Old `autoload/js/` and `autoload/python/` directories no longer exist
- Old script files in `scripts/bin/` no longer exist

## Acceptance criteria

- [ ] `_languages/javascript/` contains is-js, eslintd-restart, js-pretty and their tests
- [ ] `_languages/python/` contains is-python, python-test-path, pip-* and their tests
- [ ] `_languages/bats/` contains is-bats, bats-test-path, bats-test-list-raw, fixtures and their tests
- [ ] `_languages/zsh/` contains is-zsh, is-zsh-autoload-function and their tests
- [ ] bats-test-path and python-test-path converted to autoload form (setopt/return, no shebang)
- [ ] All emptied source directories deleted
- [ ] All existing tests pass at their new locations
