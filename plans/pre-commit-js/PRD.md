## Problem Statement

JS files in oroshi have inconsistent tooling coverage:

1. The lint-staged config only lints and tests JS files under `scripts/bin/`. JS files elsewhere — root config files and `tools/` language configs — are silently skipped on commit.
2. `git-file-lint` (`vfl`) and `git-file-test` (`vft`) handle ZSH and BATS dirty files interactively, but ignore JS files entirely. A developer editing a JS file mid-session gets no feedback until they commit.

## Solution

Two complementary fixes:

1. Expand the lint-staged JS rule to match all `.js` files in the repo, so every staged JS file gets linted and tested on commit.
2. Add JS support to `git-file-lint` and `git-file-test`, backed by a new `is-js` helper, so dirty JS files get the same interactive lint/test experience as ZSH and BATS files.

## User Stories

1. As a developer, I want all staged `.js` files to be linted on commit, so that formatting and ESLint violations are caught before they land in the repo.
2. As a developer, I want all staged `.js` files to have their related tests run on commit, so that regressions in JS logic are caught immediately.
3. As a developer, I want root config files (`eslint.config.js`, `prettier.config.js`, etc.) to be linted on commit, so that config drift is caught early.
4. As a developer, I want `tools/` JS config files to be linted on commit, so that language tool configs stay consistent with the rest of the codebase.
5. As a developer, I want the test step to be a no-op for JS files that have no related tests, so that committing a config file does not produce a spurious test failure.
6. As a developer, I want no duplicate lint/test runs on any single file, so that commit hooks remain fast.
7. As a developer, I want `vfl` to lint all dirty JS files in my working tree, so that I can catch ESLint violations while I work, not just at commit time.
8. As a developer, I want `vft` to run tests for all dirty JS files in my working tree, so that I can verify JS logic mid-session.
9. As a developer, I want `is-js` to correctly identify `.js` files and extensionless files with a node shebang, so that the tooling covers all JS entry points consistently.

## Implementation Decisions

### Issue 01 — lint-staged rule

- The lint-staged JS rule pattern is widened from `scripts/bin/**/*.js` to `**/*.js`. The broader pattern is a strict superset, so the old entry is replaced rather than kept alongside.
- The `--js` flag passed to `aberlaas lint --fix` is preserved. It scopes aberlaas to run only the ESLint linter, skipping CSS/HTML/JSON/YML linters.
- The `--fail-fast --related` flags passed to `aberlaas test` are preserved. Vitest's `--related` mode finds test files that import the staged source file; if none exist, aberlaas swallows the `VITEST_FILES_NOT_FOUND` error and exits 0.
- `tmp/` is gitignored and will never appear as a staged file, so no explicit exclusion is needed.
- `node_modules/` is never staged, so no explicit exclusion is needed there either.

### Issue 02 — `is-js` helper

- A new `is-js` autoload function follows the same structure as `is-bats` and `is-zsh`.
- Identification logic: `.js` extension → match; any other extension → no match; no extension → check first line for `#!/usr/bin/env node` shebang.
- Symlinks and non-regular files are rejected (same guard as `is-bats`/`is-zsh`).

### Issue 03 — `git-file-lint` JS support

- A JS branch is added to `git-file-lint`, mirroring the existing ZSH and BATS branches.
- All dirty JS files are accumulated in a `jsFiles` array using `is-js`.
- Lint is invoked once in batch: `yarn run lint:fix --js ${jsFiles[@]}`. Yarn automatically resolves the repo root, so no `cd` is needed.
- Results are displayed via the existing `displayLintErrors` helper.

### Issue 04 — `git-file-test` JS support

- A JS branch is added to `git-file-test`.
- All dirty JS source file paths are accumulated.
- Tests are run in a single call: `yarn run test --fail-fast --related ${jsPaths[@]}`. Vitest resolves related test files automatically — no `js-test-path` helper is needed.
- If Vitest finds no related tests (all files are config-only), aberlaas exits 0 silently.

## Testing Decisions

- **Issue 01** — config file is the artifact; no automated tests.
- **Issue 02** — `is-js` gets a BATS test suite modelled on `is-bats` and `is-zsh` tests: covers `.js` extension, other extensions, extensionless with node shebang, extensionless with other shebang, symlink, directory.
- **Issue 03** — `git-file-lint` changes are integration-level; no new unit tests.
- **Issue 04** — `git-file-test` changes are integration-level; no new unit tests.

## Out of Scope

- Linting or testing non-JS file types (`.ts`, `.mjs`, `.cjs`).
- Changes to the `aberlaas lint` or `aberlaas test` internals.
- Adding JS tests for files that currently have none (`tools/` configs, root configs).
- Cleaning up `scripts/etc/` or other unrelated JS/non-JS files.
- A `js-test-path` helper (Vitest's `--related` flag makes it unnecessary).
