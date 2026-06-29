## TLDR

Create a standalone `compdef-glob-from-group` helper that builds a `_files -g` glob from any FILETYPES group name.

## What to build

New file `completion/compdef-glob-from-group` defining a `compdef-glob-from-group` function. It always calls `filetypes-load-definitions` (idempotent), then iterates `$FILETYPES` keys to collect patterns for the requested group, and prints a full glob: `*.{ext1,ext2,...}`.

New file `completion/__tests__/compdef-glob-from-group.bats` with unit tests. Tests inject FILETYPES directly (via `bats_mock_env`) rather than sourcing the real dist file.

## Behavioral Tests

**Given a FILETYPES with two archive entries and one non-archive entry:**
- returns a glob containing both archive extensions
- does not include the non-archive extension in the glob
- output starts with `*.{` and ends with `}`

## Acceptance criteria

- [ ] `completion/compdef-glob-from-group` file exists with the `compdef-glob-from-group` function
- [ ] Always calls `filetypes-load-definitions`
- [ ] Returns `*.{...}` glob for the given group
- [ ] All behavioral tests pass (`bats completion/__tests__/compdef-glob-from-group.bats`)
- [ ] File passes `zsh-lint`
