## TLDR

Create `filetypes-load-definitions` — an autoload function that lazily sources `dist/filetypes.zsh` and is a no-op if `FILETYPES[]` is already populated.

## What to build

Create an autoload function `filetypes-load-definitions` alongside the existing
`colors-load-definitions` and `icons-load-definitions` functions. It follows the same pattern:

- Guard at the top: return early if `${#FILETYPES}` is already greater than zero
- Otherwise: source `dist/filetypes.zsh` from `$OROSHI_ROOT`

The no-op guard makes the array mockable in tests — a test can pre-populate `FILETYPES[]`
and the function will not overwrite it.

## Behavioral Tests

**No-op behavior:**
- When `FILETYPES[]` is already populated, calling `filetypes-load-definitions` does not re-source the file
- When `FILETYPES[]` is empty, calling `filetypes-load-definitions` sources `dist/filetypes.zsh` and populates the array

Prior art: `colors-load-definitions.bats`, `icons-load-definitions.bats`

## Acceptance criteria

- [ ] Function exists as an autoload in the correct directory
- [ ] Guard uses `((${#FILETYPES} > 0)) && return` pattern
- [ ] Sources `$OROSHI_ROOT/tools/term/zsh/config/theming/dist/filetypes.zsh`
- [ ] Bats tests pass (no-op case + sourcing case)
