## Guidance

### Goal

Replace 160+ `COLOR_*` exported shell variables with a single ZSH associative array `COLORS[]`, backed by two generated dist files. Zero color-related variables in the shell environment at the end.

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
| ANSI integer for raw color | `$COLORS[yellow-7]` |
| Hex string for raw color | `$COLORS[yellow-7:hex]` |
| ANSI integer for alias | `$COLORS[git-branch]` |
| Hex string for alias | `$COLORS[git-branch:hex]` |

Keys are kebab-case (all lowercase, underscores → hyphens). Aliases have no `alias-` prefix in array keys. Array name is `COLORS` (uppercase).

### Template placeholder syntax

Config template files (`src/oroshi.xml`, `src/rgrc.conf`, `src/gitconfig`) use `{{kebab-name}}` and `{{kebab-name:hex}}`. The `colors-template-render` function reads a filepath and writes the rendered content to stdout.

### `dist/colors.json` shape

```json
{ "yellow-7": { "ansi": 87, "hex": "#a16207" }, "git-branch": { "ansi": 17, "hex": "#d69e2e" } }
```

Keys are kebab-case.

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

Find all `$COLOR_*` references, apply these substitutions (key = strip prefix, lowercase, `_` → `-`):
- `$COLOR_RED` → `$COLORS[red]`
- `$COLOR_RED_HEXA` → `$COLORS[red:hex]`
- `$COLOR_ALIAS_GIT_BRANCH` → `$COLORS[git-branch]` (strip `ALIAS_`, no prefix in key)
- `$COLOR_ALIAS_GIT_BRANCH_HEXA` → `$COLORS[git-branch:hex]`

Find all `$colors[UPPERCASE_SNAKE]` references, apply:
- `$colors[GIT_BRANCH]` → `$COLORS[git-branch]`
- `$colors[GIT_BRANCH:hex]` → `$COLORS[git-branch:hex]`

Add `colors-load-definitions` call before first color use if the file is a standalone script.

## Discoveries

_Agents append findings here after each issue._

### Issue 07 — zsh consumers: statusbar + misc

- `$COLORS[${var:l}]` with an empty `var` expands to `$COLORS[]` — ZSH treats the empty subscript as a math expression and raises `bad math expression: empty string`. Guard with `${var:+$COLORS[${var:l}]}` so the lookup is skipped when `var` is empty.
- 5 statusbar scripts listed in the issue (`statusbar-battery`, `statusbar-clock`, `statusbar-dropbox`, `statusbar-spotify`, `statusbar-sound-mode`) do not exist in the repo; only `statusbar-cpu`, `statusbar-ram`, and `statusbar-ping` were present and migrated.
- `git-branch-color` bats tests referenced the old `$colors[GIT_BRANCH_*]` array (pre-issue-09); updated to `$COLORS[git-branch-*]` as part of this issue.

### Issue 09 — colors rename to COLORS + kebab keys

- Use `|` as the outer delimiter in perl when the replacement contains `/` (e.g., `perl -pi -e 's|pattern|replacement|ge'`); using `/` as outer delimiter causes `\/` escape sequences to be silently consumed in the replacement, stripping `:hex` suffixes.
- `projects-build` jq `bgInactiveName` logic uses `split("_")[0]` for uppercase; the kebab equivalent is `gsub("-[0-9]+$"; "") | "dark-" + .`; same semantic for base colors and numeric-suffix variants.
- `GRAY_WHITE` was a pre-existing dangling key in `exa.zsh` (no such color in the palette); it became `gray-white` after the rename — still dangling, noted in review-log.

### Issue 06 — zsh consumers: prompt + tools

- `nnn.zsh` uses `${(l:2::0:)colors[KEY]}` (ZSH padding modifier) — grep for `\$colors\[` won't match; use `colors\[` (without `$`) in structural tests.
- `$COLORS_RED_8` in `ruby.zsh` was a pre-existing typo (extra `S`); migrated to `$colors[RED_8]`.
- `colors-load-definitions` is NOT added to individual consumer files — the call chain (theming/index.zsh loading dist/colors.zsh) guarantees the array is populated before any of these files run.

### Issue 03 — colors-template-render

- Perl `s/pattern/{{$1:hex}}/g` fails silently if `{` in the replacement is misinterpreted; use `\x7b\x7b$1:hex\x7d\x7d` or `|` delimiters to avoid the issue.
- Two aliases (`HEADING`, `REQUIRE`) used in `oroshi.xml` don't exist in `dist/colors.zsh`; they render as unknown placeholders (left unchanged), which is correct per spec but worth noting for future alias additions.
- `local key` before a `for` loop is a forced split from assignment — zshlint accepts it without violation.

### Issue 01 — colors-build

- `$varname:hex` inside double-quoted strings is parsed by zsh as `${varname:h}ex` (`:h` = path head modifier, returns `.` for names without slashes). Use `${varname}:hex` to prevent modifier interpretation.
- `colorRangeValue` for single-digit ANSI numbers (0–9) becomes `""` via `${n:0:-1}` — the `== ""` guard skips them correctly (they're handled by `namedColors` instead).
