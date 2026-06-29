## Problem Statement

Archive file type completions in the shell are driven by a hardcoded extension list in `compdef.zsh`. This list has drifted from the canonical `FILETYPES` data source: seven archive extensions present in the compdef glob (`Z`, `bz2`, `htmlz`, `tar`, `tar.bz2`, `tar.lzma`, `tbz2`) are missing from `src/filetypes.jsonc`. Any future addition of an archive type requires updating two places — the source data and the compdef glob — with no enforcement of consistency.

## Solution

Establish a single source of truth for archive (and other filetype group) completions by:

1. Adding the missing archive extensions to the filetype source data and rebuilding the dist file.
2. Extracting a reusable helper that builds a `_files -g` glob pattern from any FILETYPES group name.
3. Updating the Archives completion block to call that helper instead of using a hardcoded list.

From this point on, adding a new archive type to the source data automatically propagates to shell completions — no separate compdef edit required.

## User Stories

1. As a shell user, I want `extract` to tab-complete `.bz2`, `.tar`, `.tar.bz2`, `.tar.lzma`, `.tbz2`, `.Z`, and `.htmlz` files, so that all supported archive formats are offered as completions.
2. As a shell user, I want archive completions to stay in sync with the filetype color/icon definitions, so that there is no inconsistency between how files are displayed and how they are completed.
3. As a developer, I want to add a new archive type in one place (`src/filetypes.jsonc`), so that it is reflected in completions without a separate edit.
4. As a developer, I want a `compdef-glob-from-group` helper that accepts any FILETYPES group name and returns a ready-to-use glob, so that image, video, and other groups can adopt the same pattern in the future.
5. As a developer, I want `compdef-glob-from-group` to be unit-testable in isolation, so that regressions are caught without loading the full completion system.
6. As a developer, I want `filetypes-load-definitions` to be called internally by the helper, so that callers do not need to know about the data loading step.

## Implementation Decisions

- **`src/filetypes.jsonc` is the source of truth.** `dist/filetypes.zsh` is a generated artifact and must not be edited directly. The build script (`filetypes-build`) resolves color and icon keys and writes the dist file; it must be re-run after any source change.

- **Seven extensions added to the `archive` group** in `src/filetypes.jsonc`: `Z`, `bz2`, `htmlz`, `tar`, `tar.bz2`, `tar.lzma`, `tbz2`. All follow the existing plain-string pattern (`"ext"` → glob `*.ext`). `ZIP` (uppercase) is excluded because the build script lowercases all keys, causing a collision with the existing `zip` entry.

- **`compdef-glob-from-group` is a standalone file** in the `completion/` directory, sourced by `compdef.zsh`. It is not an autoloaded function. It is defined, used throughout the file, then `unfunction`'d — following the same pattern as `oroshi-completion-styling` in `styling.zsh`.

- **Function interface:** `compdef-glob-from-group <group>` — calls `filetypes-load-definitions` internally, iterates `$FILETYPES` keys where `:group == <group>`, and prints the full glob pattern `*.{ext1,ext2,...}`. No sorting of extensions.

- **`compdef.zsh` Archives block** replaces the hardcoded glob with `"$(compdef-glob-from-group archive)"`. The `compdef-glob-from-group` file is sourced at the top of `compdef.zsh`.

- **`compdef-glob-from-group` is named without the `oroshi-` prefix** because it is file-scoped (unfunction'd after use), not a persistent shell utility.

## Testing Decisions

Good tests verify external behavior against a controlled environment — they mock collaborators (OROSHI_ROOT, FILETYPES) rather than reproduce internal state, and they assert on observable outputs (exit code, stdout, populated array values).

**`compdef-glob-from-group.bats`** (new):
- Test that it returns `*.{...}` containing exactly the extensions from the injected FILETYPES group.
- Test that extensions from other groups are excluded.
- Test that `filetypes-load-definitions` is not called again when FILETYPES is already populated (no-op guard).
- Prior art: `filetypes-load-definitions.bats` for the FILETYPES mock pattern; `filetypes-build.bats` for the THEMING_ROOT / OROSHI_ROOT fixture setup pattern.

**No new tests for `filetypes-build.bats`:** the build mechanism is already tested; adding data entries to the JSONC does not change the mechanism.

**No new tests for `filetypes-load-definitions.bats`:** the function is unchanged.

## Out of Scope

- Updating other `compdef.zsh` groups (images, videos, etc.) to use `compdef-glob-from-group` — that is a follow-on.
- Handling the `ZIP` uppercase extension (key collision in the build script).
- Adding a lint rule that enforces compdef globs must be driven from FILETYPES.
- Any changes to the `filetypes-build` script itself.

## Further Notes

The `compdef-glob-from-group` file lives alongside `compdef.zsh` rather than in the `autoload/` tree because its scope is currently limited to the completion config layer. If future callers outside of `completion/` need it, it should be promoted to an autoloaded function.
