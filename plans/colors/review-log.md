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

### Spec: NeoVim trigger uses full `$OROSHI_ROOT` path
```lua
executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/colors-build")
```
**Problem:** Reviewer flagged as potentially not matching "same pattern as `projects-build`".
**Reason skipped:** This IS the same pattern — `projects-build` trigger uses `executeCommand("$OROSHI_ROOT/tools/term/zsh/config/theming/projects-build")`.
