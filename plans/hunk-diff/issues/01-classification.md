## TLDR

Pure function that classifies new-side lines as `+` (added), `~` (modified), `-` (deletion marker), or context, from hunkdiff's `changes` array.

## What to build

A JS module exporting a `classifyLines` function.

**Input:**
- `changes` — array of `{ hunkIndex, kind: "added" | "removed", range: [start, end] }` (the `ExtensionFileChangeRange` array from hunkdiff's file view input)
- `totalLines` — number of lines in the new-side document

**Output:**
- `Map<number, { marker: "+" | "~" | "-", hunkIndex: number }>` — maps new-side line numbers (1-based) to their marker type. Lines not in the map are context (unchanged).

**Classification rules:**

1. Group changes by `hunkIndex`.
2. Within a hunk, collect all `removed` ranges and all `added` ranges.
3. An `added` line is `~` (modified) if any `removed` range in the same hunk is adjacent to or overlapping with the `added` range. Adjacent means the removed range's end is >= the added range's start - 1.
4. An `added` line with no nearby `removed` range is `+` (purely added).
5. A `removed` range with no corresponding `added` range: the first new-side line at or after the removed range's start gets a `-` marker. If that line already has `~` or `+`, the `-` is suppressed.
6. Priority: `~` > `+` > `-`.

The module lives at `tools/git/hunk/extensions/lib/classify.js`. Tests live at `tools/git/hunk/extensions/lib/__tests__/classify.test.js`.

## Behavioral Tests

**classifyLines**

- purely added lines get `+` marker
- purely removed range marks next surviving line as `-`
- added range adjacent to removed range in same hunk marks added lines as `~`
- added range with no removed range in same hunk marks lines as `+`
- when a line would be both `-` and `+`, `+` wins
- when a line would be both `-` and `~`, `~` wins
- removed range at end of file with no surviving line produces no `-` marker
- multiple hunks are classified independently

## Acceptance criteria

- [ ] `classifyLines` function exported from `tools/git/hunk/extensions/lib/classify.js`
- [ ] All behavioral tests pass
- [ ] Function is pure (no side effects, no hunkdiff imports)
