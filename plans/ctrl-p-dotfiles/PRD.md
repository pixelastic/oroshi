## Problem Statement

The ctrl-p file picker (fzf-based) mishandles dotfile config files (`.fdignore`, `.gitignore`, `.nvmrc`, `.npmrc`, etc.) in three ways: they appear before regular files in the sorted list (`.` sorts before letters), they render in plain white instead of their defined violet color, and the preview header shows no color or icon for them. The root cause in all cases is that the FILETYPES key for dotfiles is derived from the full filename with dots replaced by underscores (e.g. `_fdignore`), but the runtime lookup only ever uses the file extension (e.g. `fdignore`), which does not match any key.

## Solution

Introduce a new `filetypes-key` autoload function that encapsulates the correct FILETYPES key derivation for any filename: dotfiles (starting with `.`) map to `_`-prefixed lowercased keys, regular files map to their lowercased extension. Replace all ad-hoc extension lookups with calls to this function. Fix the sort order by sub-weighting dotfiles after regular files at every level of the directory tree.

## User Stories

1. As a developer using ctrl-p, I want `.fdignore` to appear after `Makefile` in the file list, so that regular files are visually grouped before dotfiles.
2. As a developer using ctrl-p, I want `.gitignore` to appear after regular files at the root level, so that the sort order reflects file importance.
3. As a developer using ctrl-p, I want dotfiles to appear after regular files within any subdirectory (not just root), so that the ordering is consistent across the whole tree.
4. As a developer using ctrl-p, I want `.fdignore` to display in violet in the file list, so that I can visually identify config files at a glance.
5. As a developer using ctrl-p, I want `.gitattributes` to display in violet in the file list, so that all dotfile config files are consistently colored.
6. As a developer using ctrl-p, I want `.nvmrc` to display in its defined color in the file list, so that the theming system works for all registered dotfiles.
7. As a developer using ctrl-p, I want the preview header for `.fdignore` to show the correct icon and color, so that the preview is visually consistent with the list.
8. As a developer using ctrl-p, I want the preview header for `.gitignore` to show the correct icon and color, so that all dotfile config files are properly themed in the preview.
9. As a developer calling `filetype-group ./some/.fdignore`, I want the correct group (`config`) returned, so that any tooling depending on filetype group works for dotfiles.
10. As a developer, I want the FILETYPES key derivation logic to live in one place, so that adding a new dotfile pattern to `filetypes.jsonc` automatically works everywhere without touching multiple files.

## Implementation Decisions

### New module: `filetypes-key`

A new autoload function that takes a filename (or filepath) and writes the corresponding FILETYPES lookup key to `$REPLY` (no subprocess, consistent with the `colorize --reply` pattern in this codebase).

Key derivation rule — mirrors the `filetypes-build` compile step exactly:
- If filename starts with `.` → lowercase the full filename and replace all dots with underscores (e.g. `.fdignore` → `_fdignore`, `.babelrc.json` → `_babelrc_json`)
- Otherwise → return the lowercased extension (e.g. `app.js` → `js`)

No FILETYPES array access — the function only computes the key. Callers do their own lookup.

### Modified: color lookup in fzf list (`fzf-colorize-path`)

Replace the inline extension extraction with a call to `filetypes-key`. Eliminates the per-file extension/dotfile branching at the callsite.

### Modified: icon + color lookup in preview header (`fzf-fs-preview`)

Replace the inline extension extraction with a call to `filetypes-key` for both icon and color lookup.

### Modified: group lookup (`filetype-group`)

Replace the inline `${filepath:e:l}` extension extraction with a call to `filetypes-key`. Fixes dotfile group resolution as a side effect.

### Modified: sort weight in `sort-filepaths`

At every level of the path (root files and DFS filename component), sub-weight dotfiles after regular files:
- Regular file → prefix `0a`
- Dotfile (starts with `.`) → prefix `0b`

Both remain before directory components (prefixed `1`) and `../` paths (prefixed `2`), preserving the existing DFS files-first ordering contract.

## Testing Decisions

Good tests verify observable outputs — sort order, REPLY value, colorized output — without asserting on internal key strings or intermediate variables.

### `filetypes-key` — full test coverage

Test the two branches of the key derivation:
- Dotfile without secondary extension (`.fdignore` → `_fdignore`)
- Dotfile with secondary extension (`.babelrc.json` → `_babelrc_json`)
- Regular file with extension (`app.js` → `js`)
- Regular file without extension (`Makefile` → empty string)

Prior art: `sort-filepaths.bats` for the pattern of testing a single autoload function via `bats_run_zsh`.

### `sort-filepaths` — extend existing test file

Add cases for:
- Root dotfile sorts after regular root file
- Root dotfile sorts before subdirectory file
- Dotfile within a subdirectory sorts after regular file in the same subdirectory

Prior art: the existing `sort-filepaths.bats` test file.

### `fzf-colorize-path` — extend existing test file

Add a case: dotfile whose FILETYPES `_`-key has a color renders in that color (stub `FILETYPES[_fdignore:color]` in the `filetypes-load-definitions` mock).

Prior art: existing `fzf-colorize-path.bats`.

### `fzf-fs-preview` — extend existing test file

Add a case: preview header for a dotfile shows the correct color and icon (stub both `_`-key entries in the mock).

Prior art: existing `fzf-fs-preview.bats`.

### `filetype-group` — no new tests

The change is a one-line delegation to `filetypes-key`, which is already tested in isolation. The group lookup behavior is covered by the `filetypes-key` tests.

## Out of Scope

- Fixing the icon double-space rendering issue (pre-existing for all filetypes, separate concern).
- Fixing `ls.zsh` LS_COLORS handling — it already iterates compiled FILETYPES keys directly and is not affected.
- Adding new dotfile entries to `filetypes.jsonc` — the existing registered dotfiles are the scope.
- Fixing sort order for dotfiles within the same directory beyond the sub-weight approach (e.g. case-insensitive sort).
