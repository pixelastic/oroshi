## TLDR

Replace all inline `*/functions/autoload/*` path checks with calls to `is-zsh-autoload-function`.

## What to build

Three files contain an inline autoload path check that duplicates the logic now centralized in `is-zsh-autoload-function`. Replace each inline check with a call to the helper:

- **`is-zsh`**: the check `[[ "$filepath" == *functions/autoload/* ]]` becomes a call to `is-zsh-autoload-function`; on `REPLY="1"` return 0.
- **`rule-missing-err-return`** (zsh-lint rule): the block that builds `$autoloadDir` and checks the path + extension is replaced by a call to `is-zsh-autoload-function`; the shebang check that follows remains in place.
- **`fzf-colorize-path`**: the extension lookup falls back to the executable check today; insert a call to `is-zsh-autoload-function` before the executable check — on `REPLY="1"`, apply `FILETYPES[zsh:color]`.

No behavior change in any of the three files. Existing bats suites (`is-zsh.bats`, `rule-missing-err-return.bats`, `fzf-colorize-path.bats`) must continue to pass without modification.

## Scaffolding Tests

None — existing bats suites serve as the regression guard for these refactors.

## Acceptance criteria

- [ ] `is-zsh`: inline autoload check replaced, existing bats pass
- [ ] `rule-missing-err-return`: inline path+extension block replaced, existing bats pass
- [ ] `fzf-colorize-path`: autoload fallback inserted before executable check, existing bats pass
- [ ] No new bats tests added (existing coverage is sufficient)
- [ ] `zsh-lint` passes on all three modified files
