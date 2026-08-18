## TLDR

Pure function that builds row descriptors from document lines and classification annotations, with 3 lines of context and `···` separators.

## What to build

A JS module exporting a `buildLayout` function.

**Input:**
- `lines` — array of strings (the new-side document split by newline)
- `annotations` — `Map<number, { marker, hunkIndex }>` (output of `classifyLines`)
- `contextSize` — number of context lines around each changed range (default 3)

**Output:**
- Array of row descriptors, each one of:
  - `{ type: "line", lineNumber: number, marker: "+" | "~" | "-" | null, content: string }`
  - `{ type: "separator" }`

**Layout rules:**

1. Collect all annotated line numbers. For each, expand to include `contextSize` lines before and after.
2. Merge overlapping or adjacent expanded ranges.
3. For each merged range, emit `line` rows for each line number in the range. The marker comes from annotations (or `null` for context lines).
4. Between non-contiguous ranges, emit a `separator` row.
5. Clamp ranges to `[1, lines.length]`.

The module lives at `tools/git/hunk/extensions/lib/layout.js`. Tests live at `tools/git/hunk/extensions/lib/__tests__/layout.test.js`.

## Behavioral Tests

**buildLayout**

- single hunk emits 3 context lines above and below changed lines
- two hunks far apart produce a separator between them
- two hunks close enough merge into one contiguous range with no separator
- context is clamped at file start (no negative line numbers)
- context is clamped at file end (no lines past document length)
- context lines have `null` marker, changed lines have their annotation marker
- empty annotations produce empty layout

## Acceptance criteria

- [ ] `buildLayout` function exported from `tools/git/hunk/extensions/lib/layout.js`
- [ ] All behavioral tests pass
- [ ] Function is pure (no side effects, no hunkdiff imports)
