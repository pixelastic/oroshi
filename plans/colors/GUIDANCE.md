## Guidance

### Goal

Replace 160+ `COLOR_*` exported shell variables with a single ZSH associative array `colors[]`, backed by two generated dist files. Zero color-related variables in the shell environment at the end.

### Key file locations

- **Source of truth:** `tools/term/kitty/config/colors.conf`
- **Build script (new):** `tools/term/zsh/config/theming/colors-build`
- **Legacy build script (to delete):** `tools/term/zsh/config/theming/src/env-generate-colors`
- **Generated ZSH (new):** `tools/term/zsh/config/theming/dist/colors.zsh`
- **Generated JSON (new):** `tools/term/zsh/config/theming/dist/colors.json`
- **Legacy generated ZSH (to delete):** `tools/term/zsh/config/theming/env/colors.zsh`
- **Template renderer (new):** `tools/term/zsh/config/functions/autoload/colors/colors-template-render`
- **Color loader (moved):** `tools/term/zsh/config/functions/autoload/colors/colors-load-definitions`
- **NeoVim trigger file:** `tools/vim/nvim/config/config/filetypes/colors.lua`
- **Refresh orchestrator:** `scripts/bin/colors-refresh`
- **Prior art — build script:** `tools/term/zsh/config/theming/projects-build`
- **Prior art — tests:** `tools/term/zsh/config/theming/__tests__/projects-build.bats`
- **Prior art — loader:** `tools/term/zsh/config/functions/autoload/project/projects-load-definitions`

### Array access contract

| Want | Use |
|------|-----|
| ANSI integer for raw color | `$colors[YELLOW_7]` |
| Hex string for raw color | `$colors[YELLOW_7:hex]` |
| ANSI integer for alias | `$colors[GIT_BRANCH]` |
| Hex string for alias | `$colors[GIT_BRANCH:hex]` |

Aliases have no `ALIAS_` prefix in array keys.

### Template placeholder syntax

Config template files (`src/oroshi.xml`, `src/rgrc.conf`, `src/gitconfig`) use `{{NAME}}` and `{{NAME:hex}}`. The `colors-template-render` function reads a filepath and writes the rendered content to stdout.

### `dist/colors.json` shape

```json
{ "YELLOW_7": { "ansi": 87, "hex": "#a16207" }, "GIT_BRANCH": { "ansi": 17, "hex": "#d69e2e" } }
```

Used by: NeoVim (`F.readJson()`), `projects-build` (`--argjson colors`).

### Testing commands

- **Run bats tests:** `bats <filepath>`
- **Lint zsh:** `zsh-lint <filepath>`
- **Lint bats:** `bats-lint <filepath>`
- Tests live in `__tests__/` directories adjacent to the file under test

### `colors-build` conventions

- Script with shebang (`#!/usr/bin/env zsh`) and `set -e`
- Accepts `THEMING_ROOT` env var override for test isolation (same pattern as `projects-build`)
- Aliases defined inline in the script (same as `env-generate-colors`)

### NeoVim Lua conventions

- Read JSON files via `F.readJson(path)` — already used in `colorscheme/init.lua` for projects
- No tests for Lua code (per project policy)

### Migration pattern for ZSH consumers

Find all `$COLOR_*` references, apply these substitutions:
- `$COLOR_NAME` → `$colors[NAME]`
- `$COLOR_NAME_HEXA` → `$colors[NAME:hex]`
- `$COLOR_ALIAS_NAME` → `$colors[NAME]`
- `$COLOR_ALIAS_NAME_HEXA` → `$colors[NAME:hex]`

Add `colors-load-definitions` call before first color use if the file is a standalone script.

## Discoveries

_Agents append findings here after each issue._

### Issue 01 — colors-build

- `$varname:hex` inside double-quoted strings is parsed by zsh as `${varname:h}ex` (`:h` = path head modifier, returns `.` for names without slashes). Use `${varname}:hex` to prevent modifier interpretation.
- `colorRangeValue` for single-digit ANSI numbers (0–9) becomes `""` via `${n:0:-1}` — the `== ""` guard skips them correctly (they're handled by `namedColors` instead).
