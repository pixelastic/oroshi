## TLDR

Wire Python into lint-staged: two yarn wrapper scripts, package.json entries, and a lintstaged.config.js entry. Also upgrade `lint-zsh` to pass `--fix`.

## What to build

1. **`scripts/yarn/lint-python`** — mirrors `lint-zsh`: accepts staged file paths, calls `python-lint --fix` on them (all `.py` files, no filtering needed since glob already ensures it).

2. **`scripts/yarn/test-python`** — mirrors `test-bats`: accepts staged file paths, resolves each via `python-test-path`, deduplicates, calls `python-test` on the found paths. Exits 0 silently if no tests found.

3. **`package.json`** — add `"lint:python": "./scripts/yarn/lint-python"` and `"test:python": "./scripts/yarn/test-python"`.

4. **`lintstaged.config.js`** — add `'**/*.py': ['yarn run lint:python', 'yarn run test:python']`.

5. **`scripts/yarn/lint-zsh`** — add `--fix` to the `zsh-lint` call.

## Acceptance criteria

- [ ] `scripts/yarn/lint-python` exists and calls `python-lint --fix` on its arguments
- [ ] `scripts/yarn/test-python` exists, resolves test paths, deduplicates, calls `python-test`
- [ ] `package.json` has `lint:python` and `test:python` entries
- [ ] `lintstaged.config.js` has a `**/*.py` entry
- [ ] `scripts/yarn/lint-zsh` calls `zsh-lint --fix`
- [ ] `zsh-lint` passes on all modified/created scripts
