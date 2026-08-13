## TLDR

Migrate `chmod-default` from `scripts/bin/misc/` to autoloaded function in `misc/`.

## What to build

Migrate `chmod-default` to `tools/term/zsh/config/functions/autoload/misc/chmod-default`:
- Remove shebang
- Replace `set -e` with `setopt local_options err_return` (if needed)
- Keep existing logic

Move tests from `scripts/bin/misc/__tests__/chmod-default.bats` to `tools/term/zsh/config/functions/autoload/misc/__tests__/chmod-default.bats`.

Delete original from `scripts/bin/misc/`.

## Scaffolding Tests

- `chmod-default` exists as autoloaded function
- Original script deleted

## Acceptance criteria

- [ ] `chmod-default` exists as autoloaded function in `misc/`
- [ ] Tests moved to `misc/__tests__/chmod-default.bats`
- [ ] Tests pass
- [ ] Passes `zsh-lint`
- [ ] Original script and tests deleted from `scripts/bin/`
