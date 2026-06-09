## TLDR

Migrate direct `source icons.zsh` calls to `icons-load-definitions`, then add a zshlint rule that enforces the call is present whenever `$ICONS[...]` is accessed.

## Context

`icons-load-definitions` already exists at `autoload/icons/icons-load-definitions` with tests — nothing to create. The same pattern exists for colors (`colors-load-definitions` + issue 11 for the lint rule).

## What to build

### Part 1 — Migrate consumers

Replace every `source $ZSH_CONFIG_PATH/theming/icons.zsh` (or equivalent) with `icons-load-definitions`.

Known files at time of writing:
- `scripts/bin/statusbar/statusbar-cpu`
- `scripts/bin/statusbar/statusbar-ram`
- `scripts/bin/statusbar/statusbar-ping`

Search for other occurrences before starting:
```
grep -r "source.*icons\.zsh" scripts/ tools/
```

### Part 2 — zshlint rule

Add a zshlint rule `noIconsAccessWithoutLoader` (follow the same implementation pattern as the equivalent colors rule in issue 11, if that rule exists by the time this runs).

Rule: any file that accesses `$ICONS[` must call `icons-load-definitions` before the first access.

Exceptions:
- `icons-load-definitions` itself
- `theming/icons.zsh` (the definition file)
- `theming/index.zsh` (the bootstrap that calls the loader)

## Acceptance criteria

- [ ] No `source.*icons\.zsh` remains in consumer files
- [ ] All consumers use `icons-load-definitions` instead
- [ ] zshlint rule `noIconsAccessWithoutLoader` (or equivalent) is implemented and active
- [ ] Rule flags a file that uses `$ICONS[` without calling `icons-load-definitions`
- [ ] Rule does not flag the exceptions listed above
- [ ] All tests pass
