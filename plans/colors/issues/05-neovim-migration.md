## TLDR

Update NeoVim colorscheme to read colors from `dist/colors.json` via `F.readJson()` instead of env vars.

## What to build

Update `tools/vim/nvim/config/config/colorscheme/init.lua`:
- Replace the `getEnvColors()` function (which iterates `COLORS_INDEX` and reads `COLOR_*_HEXA` env vars) with a call to `F.readJson()` on `dist/colors.json`
- Build `O.colors.env` from the parsed JSON table: `O.colors.env[NAME] = entry.hex` for each entry
- Path follows the same pattern as `projects.py`: `~/.oroshi/tools/term/zsh/config/theming/dist/colors.json`

`F.readJson()` and `F.readFile()` helpers already exist — no new Lua infrastructure needed.

The shape of `O.colors.env` is unchanged: a flat table of `NAME → hex_string`. Consumers of `O.colors.env` in `colorscheme/ui.lua`, `colorscheme/syntax.lua`, and `functions/highlight.lua` require no changes.

## Acceptance criteria

- [ ] `colorscheme/init.lua` no longer reads `COLORS_INDEX` env var
- [ ] `colorscheme/init.lua` no longer reads `COLOR_*_HEXA` env vars
- [ ] `colorscheme/init.lua` reads `dist/colors.json` via `F.readJson()`
- [ ] `O.colors.env` is populated with `NAME → hex` entries matching the previous behavior
- [ ] NeoVim colorscheme loads without errors (manual verification)
