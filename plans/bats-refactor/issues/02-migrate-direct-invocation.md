## TLDR

For ~62 test files where `CURRENT` holds a real binary path, inline the script name into the `bats_run_zsh` command string and remove the variable.

## What to build

Migrate every `.bats` file where `CURRENT` is assigned a path of the form `$BATS_TEST_DIRNAME/../script-name` (no extension, not a temp file) and where `CURRENT` is used only as the first argument to `bats_run_zsh`.

For each file:
1. Extract the script name from the `CURRENT=` assignment.
2. Merge that name into every `bats_run_zsh` call site, producing a single command string. Extra arguments are appended inside the string.
3. Remove the `CURRENT=` line from `setup()`.
4. If `setup()` becomes empty, delete the entire `setup()` block.
5. Run `bats <filepath>` and confirm it passes before moving to the next file.

**Quoting rules inside the merged string:**
- Arguments already in single quotes stay as-is.
- Arguments with spaces are wrapped in single quotes.
- Arguments containing an apostrophe use the `'text d'\''apostrophe'` escape.
- Heredoc redirects (`<<<`) stay outside the string — they operate on the calling shell, not inside `zsh -c`.

**Realpath variants:** A small number of files use `CURRENT="$(realpath ...)"` but only for direct invocation (not path extraction). These follow the same migration: inline the script name, drop `CURRENT`.

## Scaffolding Tests

- No `.bats` file in the migrated set contains a `CURRENT=` assignment.
- Every `bats_run_zsh` call site in migrated files uses a single command string (no `"$CURRENT"` as first token).
- No `setup()` block is empty.

## Acceptance criteria

- [ ] All ~62 direct-invocation files are migrated
- [ ] `bats <filepath>` passes for every migrated file
- [ ] `bats-lint <filepath>` passes for every migrated file
- [ ] No `CURRENT=` remains in any migrated file
- [ ] Empty `setup()` blocks are deleted
