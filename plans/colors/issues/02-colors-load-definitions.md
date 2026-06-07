## TLDR

Move `colors-load-definitions` to a new `colors/` autoload domain and update it to source `dist/colors.zsh`.

## What to build

Create the `tools/term/zsh/config/functions/autoload/colors/` domain directory.

Move `colors-load-definitions` from `autoload/project/` to `autoload/colors/` and update it:
- Guard changes: check whether the `colors` associative array is already populated (instead of checking `$COLORS_INDEX`)
- Source path changes: `dist/colors.zsh` (instead of `env/colors.zsh`)

The function signature and call sites are unchanged — callers continue to call `colors-load-definitions` with no arguments.

## Behavioral Tests

**Loading:**
- After calling `colors-load-definitions`, `$colors[YELLOW_7]` returns the correct ANSI integer
- After calling `colors-load-definitions`, `$colors[YELLOW_7:hex]` returns the correct hex string
- After calling `colors-load-definitions`, an alias such as `$colors[GIT_BRANCH]` returns the correct value

**Idempotency:**
- Calling `colors-load-definitions` a second time does not re-source `dist/colors.zsh`

## Acceptance criteria

- [ ] `colors/` autoload domain directory created
- [ ] `colors-load-definitions` lives in `autoload/colors/`
- [ ] `colors-load-definitions` removed from `autoload/project/`
- [ ] Guard checks `colors` array population, not `$COLORS_INDEX`
- [ ] Sources `dist/colors.zsh`, not `env/colors.zsh`
- [ ] Bats tests pass
