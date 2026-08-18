# New-side-only view — exploration results

## Goal

Show only the new side of diffs in hunkdiff: added lines in purple, modified
lines in violet, deleted lines completely hidden, context around changes,
**with full syntax highlighting**.

This would allow a better review process of what Claude does. This would also
allow me to upgrade Claude, as the current claude version I have still has the
old colorscheme, and the new colorscheme hurts my eyes.

## What we tried

### 1. `registerFileView` extension (implemented, works, but no syntax)

Built a working extension (`extensions/added-only.js`) that:
- Reads the new-side document via `readDocument("new")`
- Classifies lines as +/~/- via `classifyLines`
- Builds a layout with context and separators via `buildLayout`
- Renders rows with span-based tones (`added`, `removed`, `muted`, `syntax`)
- Computes `hunkRows` for hunk selection navigation
- Toggled via `v` keybinding (`registerCommand`)

**Result:** Layout works, hunk navigation works, but **no syntax highlighting**.
The `registerFileView` API replaces hunkdiff's built-in renderer entirely.
Extension rows render via `spans` (semantic tones) or `component` (React/OpenTUI),
neither of which has access to hunkdiff's Shiki/TextMate syntax engine.

### 2. Theme-only approach (explored, rejected)

Make deleted lines invisible via theme colors:
- `removedBg`, `removedContentBg` → terminal background
- `removedSignColor` → terminal background

**Result:** Lines still occupy space, text still visible via syntax colors.
Not a real "hide" — just a camouflage that's obviously wrong.

### 3. Filtered patch approach (explored, parked)

Pre-filter `git diff` to remove `-` lines, pipe to `hunk patch -`:
```
git diff | remove-minus-lines | hunk patch -
```

**Result:** Would work for one-shot use (keeps syntax highlighting via built-in
renderer), but incompatible with `--watch` mode which runs git internally.
Would also lose all deletion information.

### 4. `transformChangeset` (explored, impossible)

Modify file data before rendering via `hunk.transformChangeset()`.

**Result:** The renderer draws from opaque `metadata`, not from `patch` text.
Modifying `patch` has no effect on rendering. Removing `metadata` causes the
file to be rejected. No way to alter what the built-in renderer shows.

### 5. Auto-activate file view (explored, impossible)

`fileViews.select()` is only available in `ExtensionCommandContext` (command
handlers triggered by keypress). Not available in:
- Factory function
- `startup`, `changeset_loaded`, `file_viewed` event handlers
- Custom event bus handlers
- Keyboard mode handlers

File views are opt-in per-file via keybinding. No global default.

## What would fix this

Any ONE of these hunkdiff features would unblock the goal:

1. **Built-in `mode = "new-only"`** — a rendering mode that hides old-side lines
   while keeping syntax highlighting, similar to how `mode = "unified"` vs
   `"split"` changes layout without losing features.

2. **Syntax highlighting in file view extensions** — expose the Shiki/TextMate
   engine to `registerFileView` layouts, e.g. a `syntaxHighlight(content, language)`
   helper, or a `"syntax-highlighted"` span tone that applies per-token coloring.

3. **Per-row backgrounds in file view spans** — a `background` property on
   `ExtensionFileViewRow` that sets the row's bg color, so extensions can
   visually distinguish changed vs context lines without needing `component`.

4. **Writable metadata in `transformChangeset`** — let transforms rebuild
   metadata from a modified patch, so removing `-` lines from the patch
   actually changes what the renderer draws.

5. **Auto-active file views** — `fileViews` in event context (especially
   `changeset_loaded`), or a `defaultActive: true` option on `registerFileView`.

## Versions tested

- hunkdiff 0.18.0-beta.0 (installed, runtime tested)
- hunkdiff 0.19.0 (types inspected, not installed)
  - Adds: `registerKeyboardMode`, `registerLineHighlighter`, `fileViews.refresh()`,
    `fileViews.enterMode()`, `ExtensionCommandControls.execute()`, `configureSession()`
  - Does NOT add: syntax in file views, auto-active views, writable metadata

## Key discoveries

- Extensions can't use bare npm imports (`golgoth`, `lodash`). Hunkdiff resolves
  imports from its own context. Workaround: absolute path imports to the repo's
  `node_modules` (e.g. `import _ from '/home/tim/.oroshi/node_modules/golgoth/lodash.js'`).
- `react` IS available (served by hunkdiff at runtime).
- `selectedHunk` theme color was causing cyan backgrounds — set to `{{gray-6:hex}}`.
- `contextContentBg` also needed fixing — set to `{{terminal:hex}}`.
- The extension file view DOES work for layout control, just without syntax highlighting.

## Current state

The `added-only.js` extension is functional and deployed. It provides a
span-based new-side-only view toggled with `v`. Useful as a quick reference
but not a replacement for the built-in diff view due to missing syntax
highlighting.

Revisit when hunkdiff ships any of the features listed above.
