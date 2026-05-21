## PRD

[zshlint-precommit/PRD.md](./PRD.md)

## What to build

Move shellcheck configuration out of the linter script and into a tracked config file. Create `config/term/shellcheck/shellcheckrc.config` containing all the `disable=` directives and `external-sources=true`. Update `zshlint-shellcheck` to drop its hardcoded `excludedRules` array and instead pass `--rcfile $OROSHI_ROOT/config/term/shellcheck/shellcheckrc.config` to shellcheck.

Move the `shellcheck` and `shfmt` install scripts from `scripts/install/_languages/shell/` to `scripts/install/term/`, as siblings of `kitty` and `zsh`. Delete the now-empty `_languages/shell/` directory.

The linting behaviour must be identical before and after — same rules excluded, same output format.

## Acceptance criteria

- [ ] `config/term/shellcheck/shellcheckrc.config` exists and contains all previously hardcoded `disable=` rules plus `external-sources=true`
- [ ] `zshlint-shellcheck` no longer contains a hardcoded `excludedRules` array
- [ ] `zshlint-shellcheck` passes `--rcfile` pointing to the new config file using `$OROSHI_ROOT`
- [ ] `scripts/install/term/shellcheck` exists (moved from `_languages/shell/`)
- [ ] `scripts/install/term/shfmt` exists (moved from `_languages/shell/`)
- [ ] `scripts/install/_languages/shell/` no longer exists
- [ ] Running `zshlint` on an existing ZSH file produces the same output as before the migration

## Blocked by

None — can start immediately.
