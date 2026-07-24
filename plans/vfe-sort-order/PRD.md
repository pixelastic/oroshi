## Problem Statement

`git-file-edit` (alias `vfe`) opens dirty files in neovim tabs in `git status --porcelain` order. Test files in `__tests__/` directories sort alphabetically before their source files, so the review flow is test-then-code instead of code-then-test. Additionally, language-specific autoload functions (`is-*`, `*-test-path`) are scattered across `autoload/term/<lang>/` and `scripts/bin/<lang>/` with no coherent domain structure.

## Solution

Sort the file list so each source file is immediately followed by its corresponding test file (code-then-test pairs). Introduce a generic `test-path` dispatcher that delegates to language-specific `*-test-path` functions. Consolidate all language-specific autoload functions under a new `autoload/_languages/` domain hierarchy.

## User Stories

1. As a developer running `vfe`, I want source files to open before their test files, so that I review code before its tests
2. As a developer running `vfe`, I want paired source and test files to be adjacent tabs, so that I can easily switch between them
3. As a developer running `vfe` with only test files dirty, I want those test files to still appear in the tab list, so that nothing is silently dropped
4. As a developer running `vfe` with only source files dirty (no matching test modified), I want the source files to appear normally, so that the sort doesn't break the default case
5. As a developer, I want a single `test-path` function that finds the test file for any source file regardless of language, so that consumers don't need to know language-specific conventions
6. As a developer working on JS files, I want `js-test-path` to resolve `dir/foo.js` to `dir/__tests__/foo.js`, so that JS test pairing follows the same pattern as other languages
7. As a developer, I want all language-specific functions (`is-*`, `*-test-path`, utilities) grouped under `_languages/<lang>/`, so that the autoload directory structure mirrors the existing `tools/_languages/` convention
8. As a developer, I want `bats-test-path` and `python-test-path` converted from scripts to autoload functions, so that they load consistently with the rest of the function library

## Implementation Decisions

### Generic `test-path` dispatcher
- Located in `autoload/misc/`
- Early return (`return 1`) for `.bats` files (no test for a test)
- Dispatch chain: `is-js` then `js-test-path`, `is-python` then `python-test-path`, fallback `bats-test-path`
- Returns test file path on stdout, or `return 1` if no match (same contract as individual `*-test-path` functions)

### New `js-test-path`
- Located in `autoload/_languages/javascript/`
- Convention: `dir/foo.js` maps to `dir/__tests__/foo.js` (same basename and extension)
- If input is already a JS test file (parent dir is `__tests__`), return it directly
- Returns `return 1` if no matching test file exists on disk

### `git-file-edit` sort algorithm
- Two-list approach with a `consumed` associative array
- Iterate `fileList` in original order; for each file, add to `sortedList`
- Call `test-path` on each file; if result exists in `fileList` and not yet consumed, append to `sortedList` and mark consumed
- Consumed files are skipped when encountered later in the iteration
- Final `nvim -p $sortedList`

### Script-to-autoload conversion for `bats-test-path` and `python-test-path`
- Replace `set -e` with `setopt local_options err_return`
- Replace `exit 1` with `return 1`
- Remove shebang line
- Delete original scripts from `scripts/bin/`

### `_languages/` domain reorganization
- New directory: `autoload/_languages/` with subdirectories `javascript/`, `python/`, `bats/`, `zsh/`
- Naming follows `tools/_languages/` convention (plural, single underscore prefix)
- Migrations:
  - `autoload/term/js/` contents (is-js + test) to `_languages/javascript/`
  - `autoload/term/python/` contents (is-python + test) to `_languages/python/`
  - `autoload/term/bats/` contents (is-bats, bats-test-list-raw, fixtures + tests) to `_languages/bats/`
  - `autoload/term/zsh/` contents (is-zsh, is-zsh-autoload-function + tests) to `_languages/zsh/`
  - `autoload/js/` contents (eslintd-restart, js-pretty) to `_languages/javascript/`
  - `autoload/python/` contents (pip-list, pip-list-raw, pip-package-colorize, pip-update + test) to `_languages/python/`
- Empty source directories deleted after migration

## Testing Decisions

Tests verify external behavior: given an input file path, does the function return the correct test path (or fail correctly)?

### Modules tested
- **`test-path`** — new dispatcher, needs tests for each language branch, early return for `.bats`, and fallback behavior for unrecognized file types
- **`js-test-path`** — new function, needs tests mirroring the existing `bats-test-path.bats` and `python-test-path.bats` patterns (valid source, already-a-test, missing test, no argument)
- **`git-file-edit`** — sort order behavior (source before test, unpaired files preserved, test-only files preserved)
- **Migrated functions** — existing tests for `is-js`, `is-python`, `is-bats`, `is-zsh`, `is-zsh-autoload-function`, `bats-test-path`, `python-test-path`, `pip-list` must pass after migration

### Prior art
- `scripts/bin/term/bats/__tests__/bats-test-path.bats` — pattern for testing `*-test-path` functions (create temp files, call function, assert output path)
- `scripts/bin/python/__tests__/python-test-path.bats` — same pattern for Python convention
- All tests use `bats_load_library 'helper'`, `bats_run_zsh`, and `$BATS_TMP_DIR` for fixtures

## Out of Scope

- Modifying `git-file-test` to use the new `test-path` dispatcher
- Modifying `git-file-list-dirty-raw`
- Lua test path migration or `is-lua` creation
- `ARG_MAX` mitigation for `nvim -p`
- Moving `is-*` detectors from `autoload/term/zsh/` to a different domain than `_languages/zsh/`

## Further Notes

- `bats-test-path` is the most permissive: it accepts any file (ZSH autoload, shell scripts) and builds `dir/__tests__/basename.bats`. This makes it the correct fallback in `test-path`.
- The `_languages/` reorganization is opportunistic: triggered by having a new consumer (`test-path`) that touches all language domains, making it the right time to consolidate.
