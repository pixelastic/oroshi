## TLDR

Add `--reply` flag to `filetypes-group` to write result to `$REPLY` instead of echoing.

## What to build

Modify `tools/term/zsh/config/functions/autoload/filetypes/filetypes-group` to accept a `--reply` flag using `zparseopts`, following the same pattern as `simplify-path`.

When `--reply` is passed, write the group name to `$REPLY` instead of `echo`. Without `--reply`, behavior is unchanged.

## Behavioral Tests

Prior art: `tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-group.bats`

**--reply flag writes to REPLY**
- Given a file with a known extension (e.g. `file.png`), calling `filetypes-group --reply file.png` sets `$REPLY` to `image` with no stdout output

**without --reply, echoes as before**
- Existing tests already cover this — no changes needed

## Acceptance criteria

- [ ] `filetypes-group --reply file.png` sets `$REPLY` to `image`
- [ ] `filetypes-group --reply file.png` produces no stdout
- [ ] `filetypes-group file.png` still echoes `image` (backward compat)
- [ ] Tests pass: `bats tools/term/zsh/config/functions/autoload/filetypes/__tests__/filetypes-group.bats`
