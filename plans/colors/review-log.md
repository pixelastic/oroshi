## Issue 01 — colors-build

### Standards: `local` at script scope / constants not UPPER_CASE
```zsh
local themingRoot="${THEMING_ROOT:-${0:A:h}}"
local kittyConf="${themingRoot:h:h:h}/kitty/config/colors.conf"
```
**Problem:** Reviewer flagged script-level `local` and lowercase constant names as violations of zsh-writer checklist ("script constants UPPER_CASE without `local`").
**Reason skipped:** `projects-build` (direct prior art referenced in the issue) uses the identical pattern throughout. This is the established convention in this codebase.

### Standards: No guard on missing `kittyConf`
```zsh
local kittyColors="$(grep '^color' "$kittyConf")"
```
**Problem:** Missing file check; silently produces empty output.
**Reason skipped:** `projects-build` has the same absence of input validation. Out of scope for this issue.

### Standards (bats): `COLORS_BUILD` should be named `CURRENT` — FIXED
Renamed to `CURRENT` after confirming `testing.md` explicitly documents this as the standard. `projects-build.bats` was pre-existing prior art that itself deviates.

### Standards (bats): `local script` declared in test body
```bats
local script="$BATS_TMP_DIR/verify.zsh"
```
**Problem:** Reviewer flagged as violating "all test vars go inside setup()".
**Reason skipped:** The memory note says "at file top level" — inline locals inside test bodies are fine. `projects-build.bats` does the same.

## Issue 06 — zsh consumers: prompt + tools

### `~/.oroshi` hardcoded bootstrap in `git.bats`
```zsh
source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
```
**Problem:** Memory rule says use `$OROSHI_ROOT`, not `~/.oroshi`.
**Reason skipped:** This line is the bootstrap that *sets* `$OROSHI_ROOT` — `$OROSHI_ROOT` is unavailable before sourcing `zshenv.zsh`. Pre-existing pattern used identically across all test blocks in this file.

## Issue 07 — zsh consumers: statusbar + misc

### Spec: 5 statusbar scripts absent from repo
**Problem:** Spec lists `statusbar-battery`, `statusbar-clock`, `statusbar-dropbox`, `statusbar-spotify`, `statusbar-sound-mode` as files to migrate.
**Reason skipped:** These files do not exist in the repo. Nothing to migrate.

## Issue 09 — colors rename to COLORS + kebab keys

### $COLORS[gray-white] dangling key in exa.zsh

```zsh
EXA_COLORS="${EXA_COLORS}:fi=38;5;$COLORS[gray-white]" # Default file color
```

**Problem:** `gray-white` does not exist in the color palette. Key expands to empty string; originally `$colors[GRAY_WHITE]` which also didn't exist in the palette.

**Reason skipped:** Pre-existing bug. Choosing a correct replacement color is out of scope for a mechanical rename issue.

---

## Issue 08 — colors-refresh cleanup

### Standards: unquoted `$ZSH_CONFIG_PATH` in source call
```zsh
source $ZSH_CONFIG_PATH/theming/dist/colors.zsh
```
**Problem:** zsh-writer examples show quoted variable expansions; reviewer flagged as hard violation.
**Reason skipped:** zshlint returned `[]` (linter does not enforce this). Every other path call in the same file uses the same unquoted pattern (pre-existing style throughout).

### Spec: `source env/filetypes.zsh` vs `source dist/filetypes.zsh`
```zsh
source $ZSH_CONFIG_PATH/theming/env/filetypes.zsh
```
**Problem:** Spec's final orchestration order lists `source dist/filetypes.zsh` (step 4).
**Reason skipped:** Acceptance criteria only cover colors. Filetypes migration is out of scope for this issue.

---

### Spec: NeoVim trigger uses full `$OROSHI_ROOT` path
```lua
executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/colors-build")
```
**Problem:** Reviewer flagged as potentially not matching "same pattern as `projects-build`".
**Reason skipped:** This IS the same pattern — `projects-build` trigger uses `executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/projects-build")`.
