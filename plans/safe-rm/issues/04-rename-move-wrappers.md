## TLDR

Rename `better-rm` → `rm-for-cli` and `better-rmdir` → `rmdir-for-cli`, move to `misc/rm/`, update aliases.

## What to build

File moves:
- `autoload/misc/better/better-rm` → `autoload/misc/rm/rm-for-cli`
- `autoload/misc/better/better-rmdir` → `autoload/misc/rm/rmdir-for-cli`
- `autoload/misc/better/__tests__/better-rm.bats` → `autoload/misc/rm/__tests__/rm-for-cli.bats`
- `autoload/misc/better/__tests__/better-rmdir.bats` → `autoload/misc/rm/__tests__/rmdir-for-cli.bats`

Alias update in `tools/term/zsh/config/aliases/rm.zsh`:
- `alias rm='rm-for-cli'` (was `rm='better-rm'`)
- `alias rmdir='rmdir-for-cli'` (was `rmdir='better-rmdir'`)
- `alias rmz='trash-restore'` (unchanged)

Function logic: unchanged. Only the function names and file locations change.

Tests: adapt existing test files to new function names. No new test cases — behavior is identical.

Check for any other references to `better-rm` or `better-rmdir` in the codebase and update them.

## Scaffolding Tests

**rm-for-cli:**
- Existing better-rm tests pass under the new name
- Regular files sent to trash-put
- Mounted files sent to /bin/rm

**rmdir-for-cli:**
- Existing better-rmdir tests pass under the new name
- Regular dirs sent to trash-put
- .Trash dirs sent to /bin/rm

## Acceptance criteria

- [ ] `rm-for-cli` at new path, identical behavior to `better-rm`
- [ ] `rmdir-for-cli` at new path, identical behavior to `better-rmdir`
- [ ] Old files removed from `autoload/misc/better/`
- [ ] Aliases updated in `rm.zsh`
- [ ] No remaining references to `better-rm` or `better-rmdir` in codebase
- [ ] All tests pass under new names
