## TLDR

Extend `git-file-test` to run Vitest `--related` for dirty JS files.

## What to build

Add a JS branch to `git-file-test` (`tools/term/zsh/config/functions/autoload/git/file/git-file-test`):

- In the dirty-file loop, accumulate full paths of dirty JS source files (using `is-js`) into a `jsPaths` array
- After the loop, if `jsPaths` is non-empty, call `yarn run test --fail-fast --related ${jsPaths[@]}`
- Vitest resolves related test files automatically; if none exist, aberlaas exits 0 silently — no special handling needed

No `js-test-path` helper is required.

## Behavioral Tests

None — integration-level change.

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `git-file-test` runs Vitest `--related` for dirty `.js` files
- [ ] If no related tests exist, the command exits 0 silently
- [ ] BATS test execution for non-JS dirty files is unaffected
- [ ] Deleted JS files are skipped (same guard as existing BATS logic)
