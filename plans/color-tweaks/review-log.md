## Issue 01 — Filetype Icons

### Spec: glyphs copied but not removed from filetypes-list.zsh

```zsh
# filetypes-list.zsh still contains:
FILETYPE_GROUPS[text:icon]=" "
FILETYPE_GROUPS[script:icon]=" "
# ... (all original entries unchanged)
```

**Problem:** Spec says "move the Unicode glyphs", implying removal from the source file.

**Reason skipped:** Acceptance criteria make no mention of removing entries from `filetypes-list.zsh`. The GUIDANCE.md key file table lists `filetypes-list.zsh` as "Delete" — that deletion is scoped to a later issue. Both the source and `icons.zsh` can coexist until then.

## Issue 02 — JSON source and build

### Standards: `local` at script top level is invalid ZSH
```zsh
local themingRoot="${THEMING_ROOT:-${0:A:h}}"
local srcJson="$themingRoot/src/filetypes.json"
```
**Problem:** Reviewer flagged `local` outside a function as invalid in ZSH scripts.
**Reason skipped:** `local` at script top level works in ZSH (script body runs in an implicit function context). `colors-build` and `projects-build` use the same pattern — established convention in this codebase.

### Standards: No early-return guards on missing source files
```zsh
source "$distDir/colors.zsh"
source "$themingRoot/icons.zsh"
```
**Problem:** Reviewer flagged absence of explicit guards for missing files.
**Reason skipped:** `set -e` causes the script to exit immediately if `source` fails. Guards would be redundant. Same pattern as `colors-build` and `projects-build`.

### Spec: JSON plain-string patterns grouped on one line
```json
"patterns": [
  "7z", "cbr", "cbz", "deb", "gz", ...
]
```
**Problem:** Reviewer questioned multi-string grouping vs. "each field on its own line" spec wording.
**Reason skipped:** The spec's per-line rule applies to group-level keys (`color`, `icon`, `bold`, `patterns`), not to individual string items in the patterns array. Grouping plain strings is standard JSON style.

### Spec: Dot→underscore applied to multi-dot extensions (undocumented)
```
tar_gz:pattern=*.tar.gz
```
**Problem:** Spec only documents dot→underscore for filename patterns, not extensions.
**Reason skipped:** The old `env-generate-filetypes` applied `gs/\./_/` to all patterns. Multi-dot extensions like `tar.gz` need `tar_gz` as a key (colon is the FILETYPES separator). Correct and intentional.

## Issue 03 — Load definitions

### Standards: `((${#FILETYPES} > 0))` arithmetic test

```zsh
((${#FILETYPES} > 0)) && return
```

**Problem:** Reviewer flagged `(( ))` as violating `noArithFlagTest`.
**Reason skipped:** `noArithFlagTest` targets `0/1` flag variables (`(( isFlag ))`), not arithmetic array-length expressions. Prior art `colors-load-definitions` uses the identical `((${#COLORS} > 0))` pattern and passes lint.

### Spec: `bats_mock_env FILETYPES "preset"` scalar mock

```bash
bats_mock_env FILETYPES "preset"
bats_run_zsh "filetypes-load-definitions"
```

**Problem:** Reviewer flagged that setting a scalar may not exercise the `${#FILETYPES}` array-count guard correctly.
**Reason skipped:** This is the exact pattern used in `colors-load-definitions.bats` (`bats_mock_env COLORS "preset"`). The string length is > 0, so the guard fires. Consistent with prior art.

### Spec: No-op test doesn't assert sourcing was skipped

**Problem:** Test only checks `[ "$status" -eq 0 ]` — doesn't verify the dist file wasn't sourced.
**Reason skipped:** Identical to the prior-art pattern in `colors-load-definitions.bats`.
