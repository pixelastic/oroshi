## TLDR

Convert `better-ls` from bash to ZSH and color autoloaded functions like `.zsh` scripts in `exa` output.

## What to build

Convert `better-ls` from `#!/usr/bin/env bash` to `#!/usr/bin/env zsh`. This unlocks access to `filetypes-load-definitions` and the `FILETYPES` assoc array.

Add logic: when `$PWD` matches `*/functions/autoload*`, call `filetypes-load-definitions` and append `:fi=38;5;$FILETYPES[zsh:color]` to `LS_COLORS` for the `exa` invocation only. The `fi=` key is the regular-file fallback in `LS_COLORS` — files with explicit extension matches are unaffected; only extensionless files pick up this color.

`$PWD` is always used as the detection target, regardless of any argument passed to `better-ls`. This is an accepted limitation.

Write a bats test suite. Mock `exa` with `bats_mock` to capture the `LS_COLORS` it receives.

## Behavioral Tests

**When called from a `functions/autoload/` directory:**
- `exa` is invoked with `LS_COLORS` containing `fi=38;5;<zsh-color>`

**When called from a non-autoload directory:**
- `exa` is invoked without a `fi=` override in `LS_COLORS`

## Acceptance criteria

- [ ] `better-ls` shebang changed to `#!/usr/bin/env zsh`
- [ ] `fi=` override applied to `LS_COLORS` when `$PWD` is inside an autoload directory
- [ ] Color value read from `FILETYPES[zsh:color]` — not hardcoded
- [ ] Bats test suite covers both scenarios above
- [ ] Existing behavior unchanged for non-autoload directories
- [ ] `zsh-lint` passes on the converted script
- [ ] `bats-lint` passes on the test file
