## TLDR

Migrate all 7 consumers of `git-file-list-dirty-raw` from `STATUS:filepath` to `filepath▮STATUS` parsing.

## What to build

Update these consumers to split on `▮` instead of `:` and reverse column order (filepath is now column 1, status is column 2):

1. **`git-file-edit`** — opens dirty files in nvim, skips deleted
2. **`git-file-lint`** — runs linters on dirty files, skips deleted
3. **`git-file-test`** — runs tests for dirty files, skips deleted
4. **`git-file-list-dirty`** — colorized display of dirty files
5. **`complete-git-files-dirty`** — zsh completion for dirty files
6. **`fzf-git-files-dirty`** — fzf picker for dirty files
7. **`git-directory-dirty-count`** — no change needed (counts lines only)

The migration is mechanical in each file:
- Replace `${(@s/:/)rawLine}` with `${rawLine%%▮*}` for filepath and `${${rawLine#*▮}[1]}` for status (or similar split)
- Column 1 is now filepath, column 2 is status

## Scaffolding Tests

**Existing tests that must still pass after migration:**
- `git-file-edit.bats` — file editing behavior unchanged
- `git-file-lint.bats` — linting behavior unchanged
- `git-file-test.bats` — test running behavior unchanged

These tests call the consumer functions end-to-end, so they implicitly validate the format change works through the full chain.

## Acceptance criteria

- [ ] All 6 consumers (excluding `dirty-count`) parse `filepath▮STATUS` format
- [ ] No consumer uses `:` as separator for raw output
- [ ] Existing tests for `git-file-edit`, `git-file-lint`, `git-file-test` pass
- [ ] `zsh-lint` passes on all modified files
