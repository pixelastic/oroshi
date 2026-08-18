## Problem Statement

`vfw` (git-file-watch) launches hunkdiff in watch mode to show diffs of dirty tracked files. The current display is a classic unified diff showing both deleted and added lines. This is noisy — when editing code, you only care about the new state of the file, with visual indicators showing what changed. NeoVim's gutter signs achieve this: you see only the new file content, with markers indicating additions, modifications, and deletions.

## Solution

Build a hunkdiff extension that replaces the default diff view with an "added-only" file view. The view shows only the new side of the file (hunk regions with 3 lines of context), with gutter markers:

- `+ ` green — purely added lines (no corresponding deletion in the hunk)
- `~ ` violet — modified lines (added range adjacent to a removed range in the same hunk)
- `- ` red — purely deleted lines (marker shown on the first surviving line after the deletion)
- `  ` blank — context lines (unchanged)

Priority when markers overlap: `~` > `+` > `-`.

New-side line numbers are shown. Hunks are separated by a muted `···` row.

## User Stories

1. As a developer, I want `vfw` to show only the new side of the file so that I can focus on the current state of my code.
2. As a developer, I want a `+` green marker on purely added lines so that I can see what was inserted.
3. As a developer, I want a `~` violet marker on modified lines so that I can see what was changed.
4. As a developer, I want a `-` red marker on the line after a deletion so that I can see where lines were removed, without the deleted content cluttering the view.
5. As a developer, I want 3 lines of context around each changed range so that I have enough surrounding code to understand the change.
6. As a developer, I want a `···` separator between hunks so that I can visually distinguish non-contiguous changed regions.
7. As a developer, I want new-side line numbers so that I can orient myself in the file.
8. As a developer, I want the gutter marker colors to come from my color theme so that the extension respects my terminal palette.

## Implementation Decisions

### Extension architecture

The extension uses `registerFileView` (not `transformChangeset`). `transformChangeset` operates on file-level patches with opaque metadata — line-level filtering is not possible. `registerFileView` gives full control over rendered rows.

### Custom colors via component.render

The hunkdiff `ExtensionFileViewSpan` API only supports 6 predefined tones: `muted`, `accent`, `accent-muted`, `syntax`, `added`, `removed`. There is no `modified` tone, and no way to pass arbitrary hex colors through spans. The tone set is validated at runtime against a hardcoded `Set`.

To render the `~` violet marker, each row uses the experimental `component.render` escape hatch. The render function returns OpenTUI `<span fg="...">` elements with hex color values. Spans are also provided as a degraded fallback (using `added` tone for `~` markers) in case the component render fails.

### Color sourcing

Colors are injected through the config.toml template pipeline:

1. `colors.jsonc` defines semantic colors (e.g. `git.modified` → `violet-3`)
2. `colors-build` generates `colors.json` with hex values
3. `colors-template-render` processes `config.toml`, replacing `{{git-modified:hex}}` with `#a78bfa`
4. The extension reads colors from `[extension.added-only]` via `hunk.config`

Config section:
```toml
[extension.added-only]
colorAdded = "{{git-added:hex}}"
colorModified = "{{git-modified:hex}}"
colorRemoved = "{{git-removed:hex}}"
```

### Change classification logic

The `changes` array from `ExtensionFileViewInput` provides ranges typed as `added` or `removed`, each with a `hunkIndex`. Classification:

- **Modified:** a new-side line is in an `added` range that is adjacent to or overlapping with a `removed` range in the same hunk
- **Purely added:** a new-side line is in an `added` range with no nearby `removed` range in the same hunk
- **Deletion marker:** a `removed` range exists in a hunk, and the first surviving line after it receives a `-` gutter marker (unless that line is already `~` or `+`)

### Layout generation

For each file, the extension:

1. Reads the new-side document via `readDocument("new")`
2. Computes visible line ranges: each hunk's changed lines ± 3 context lines
3. Merges overlapping ranges
4. Emits rows: line number + gutter marker + line content
5. Inserts `···` separator rows between non-contiguous ranges
6. Maps rows back to source lines via `sourceRanges` for inline note support

### Deployment

- Extension source: `tools/git/hunk/extensions/added-only.js`
- Deploy script symlinks the extension to `~/.config/hunk/extensions/added-only.js`
- Config.toml gains the `[extension.added-only]` section and an `extensions.paths` entry

## Testing Decisions

Good tests verify observable behaviour from the outside, not implementation details.

### Change classification (vitest)

The classification logic is a pure function: input is a `changes` array, output is a map of line numbers to marker types. Tested with:

- Purely added range → all lines marked `+`
- Removed + added ranges in same hunk → added lines marked `~`
- Removed range only → first surviving line marked `-`
- Overlap priority: `~` > `+` > `-`

### Layout generation (vitest)

The layout logic is a pure function: input is document lines + line annotations + context size, output is row descriptors. Tested with:

- Single hunk with 3 context lines above and below
- Two hunks close enough to merge context
- Two hunks far apart → `···` separator between them
- Deletion at start of file → `-` on first surviving line
- Deletion at end of file → no `-` marker (no surviving line after)

Prior art: `scripts/bin/` JS modules tested with vitest

## Out of Scope

- Toggling between added-only and normal diff view at runtime
- Syntax highlighting of line content (delegated to hunkdiff's host renderer via spans as fallback)
- Customizing the number of context lines (hardcoded to 3)
- Split or side-by-side layout modes
- Support for binary files or too-large files

## Further Notes

The `component.render` API is experimental (Phase 1 of hunkdiff extensions). It may change in future hunkdiff versions. The spans fallback ensures graceful degradation — if component rendering breaks, the view still shows correct content with approximate colors (green `added` tone for both `+` and `~` markers).
