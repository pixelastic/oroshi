## TLDR

Migrate statusbar scripts and miscellaneous color-consuming functions from `$COLOR_*` env vars to `$COLORS[kebab-name]` array lookups.

## What to build

In all files listed below, replace every `$COLOR_NAME` with `$COLORS[kebab-name]`, `$COLOR_NAME_HEXA` with `$COLORS[kebab-name:hex]`, `$COLOR_ALIAS_NAME` with `$COLORS[kebab-name]`, and `$COLOR_ALIAS_NAME_HEXA` with `$COLORS[kebab-name:hex]`. Ensure `colors-load-definitions` is called before first use in each file.

**Statusbar scripts** (`scripts/bin/statusbar/`):
- `statusbar-cpu`
- `statusbar-ram`
- `statusbar-battery`
- `statusbar-clock`
- `statusbar-ping`
- `statusbar-dropbox`
- `statusbar-spotify`
- `statusbar-sound-mode`

**Miscellaneous functions** (`tools/term/zsh/config/functions/autoload/`):
- `misc/colorize`
- `git/branch/git-branch-color`

**AI integration** (`tools/ai/claude/config/`):
- `statusline`

## Acceptance criteria

- [ ] No `$COLOR_` references remain in any of the listed files
- [ ] All color accesses use `$COLORS[kebab-name]` or `$COLORS[kebab-name:hex]`
- [ ] `colors-load-definitions` is called where needed before first color access
- [ ] Statusbar scripts output correct colors (manual verification)
- [ ] `git-branch-color` returns correct colors for known branch names (manual verification)
