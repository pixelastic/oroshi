## TLDR

Wire classification + layout into a hunkdiff `registerFileView` extension with OpenTUI rendering, config colors, and deploy script.

## What to build

### Extension entry point

`tools/git/hunk/extensions/added-only.js` — default-exports an extension factory:

1. Reads colors from `hunk.config`: `colorAdded`, `colorModified`, `colorRemoved`
2. Calls `hunk.registerFileView` with a view that:
   - `matches()` returns `true` for all files (replaces default view globally)
   - `layout()` calls `readDocument("new")`, runs `classifyLines` on `input.changes`, runs `buildLayout`, then converts row descriptors to `ExtensionFileViewRow` objects

### Row rendering

Each `line` row has:
- `spans` — fallback rendering using available tones (`added` for `+`/`~`, `removed` for `-`, no tone for context)
- `component` — OpenTUI rendering with exact hex colors:
  - Gutter marker: `<span fg={color}>MARKER </span>` where color/marker depends on annotation
  - Line number: `<span fg={theme.muted}>{lineNumber} </span>` (right-aligned, padded)
  - Content: `<span>{content}</span>`
- `sourceRanges` — maps rows back to new-side line numbers for inline note support
- `id` — unique row identifier

Each `separator` row has:
- `spans` — `[{ text: "···", tone: "muted" }]`
- `id` — unique separator identifier

The `hunkRows` array in the returned layout maps hunk boundaries to row indices.

### Config changes

`tools/git/hunk/config/src/config.toml` gains:

```toml
[extensions]
enabled = true

[extension.added-only]
colorAdded = "{{git-added:hex}}"
colorModified = "{{git-modified:hex}}"
colorRemoved = "{{git-removed:hex}}"
```

### Deploy changes

`tools/git/hunk/deploy` gains a symlink step:

```sh
ln -fs $SCRIPT_DIR/extensions/added-only.js $DEST_DIR/extensions/added-only.js
```

Creating `~/.config/hunk/extensions/` if needed.

## Acceptance criteria

- [ ] `vfw` opens and shows the added-only view instead of the default unified diff
- [ ] Added lines show `+` in green, modified lines show `~` in violet, deleted lines show `-` in red
- [ ] Context lines have no gutter marker
- [ ] Non-contiguous hunks are separated by `···`
- [ ] New-side line numbers are visible
- [ ] Deploy script creates the extension symlink
- [ ] Config template includes `[extension.added-only]` with color variables
